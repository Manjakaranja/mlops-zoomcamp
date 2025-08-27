#!/usr/bin/env python
# coding: utf-8

import pickle
import pandas as pd

import xgboost as xgb
import numpy as np

from sklearn.feature_extraction import DictVectorizer
from sklearn.metrics import mean_squared_error

import mlflow
from datetime import datetime
from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator




# Using absolute path to the correct DB
mlflow.set_tracking_uri("http://localhost:5000") 
mlflow.set_experiment("nyc-taxi-experiment")



def read_dataframe(year, month):
    url = f'/workspaces/mlops-zoomcamp/02-mlflow/data/green_tripdata_{year}-{month:02d}.parquet'
    df = pd.read_parquet(url)

    df['duration'] = df.lpep_dropoff_datetime - df.lpep_pickup_datetime
    df.duration = df.duration.apply(lambda td: td.total_seconds() / 60)

    df = df[(df.duration >= 1) & (df.duration <= 60)]

    categorical = ['PULocationID', 'DOLocationID']
    df[categorical] = df[categorical].astype(str)
    df['PU_DO'] = df['PULocationID'] + '_' + df['DOLocationID']
    return df



def create_X(df, dv=None):
    categorical = ['PU_DO']
    numerical = ['trip_distance']
    dicts = df[categorical + numerical].to_dict(orient='records')

    if dv is None:
        dv = DictVectorizer(sparse=True)
        X = dv.fit_transform(dicts)
    else:
        X = dv.transform(dicts)

    return X, dv

def train_model(X_train, y_train, X_val, y_val, dv):
    with mlflow.start_run() as run:

        train = xgb.DMatrix(X_train, label=y_train)
        valid = xgb.DMatrix(X_val, label=y_val)

        best_params = {
            'learning_rate': 0.09585355369315604,
            'max_depth': 30,
            'min_child_weight': 1.060597050922164,
            'objective': 'reg:squarederror',
            'reg_alpha': 0.018060244040060163,
            'reg_lambda': 0.011658731377413597,
            'seed': 42
        }

        mlflow.log_params(best_params)

        booster = xgb.train(
            params=best_params,
            dtrain=train,
            num_boost_round=30,
            evals=[(valid, 'validation')],
            early_stopping_rounds=50
        )

        y_pred = booster.predict(valid)
        mse = mean_squared_error(y_val, y_pred)
        rmse = np.sqrt(mse)
        mlflow.log_metric("rmse", rmse)

        with open("preprocessor.b", "wb") as f_out:
            pickle.dump(dv, f_out)
        mlflow.log_artifact("preprocessor.b", artifact_path="preprocessor")

        mlflow.xgboost.log_model(booster, name="models_mlflow")
        
        return run.info.run_id #Save the run_id into a text file called run_id.txt


manual_orchestration='''
def run(year, month):
    df_train = read_dataframe(year=year, month=month)

    next_year = year if month < 12 else year + 1
    next_month = month + 1 if month < 12 else 1
    df_val = read_dataframe(year=next_year, month=next_month)

    X_train, dv = create_X(df_train)
    X_val, _ = create_X(df_val, dv)

    target = 'duration'
    y_train = df_train[target].values
    y_val = df_val[target].values

    run_id = train_model(X_train, y_train, X_val, y_val, dv)
    print(f"MLflow run_id: {run_id}")
    return run_id


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description='Train a model to predict taxi trip duration.')
    parser.add_argument('--year', type=int, required=True, help='Year of the data to train on')
    parser.add_argument('--month', type=int, required=True, help='Month of the data to train on')
    args = parser.parse_args()

    run_id = run(year=args.year, month=args.month)
        with open("run_id.txt", "w") as f:
        f.write(run_id)
'''


# Initialisation of Airflow DAG
default_args = {
    'owner': 'Manza',
    'start_date': datetime(2023, 5, 22),
}

with DAG('taxi_prediction', default_args=default_args, schedule="@daily") as dag:

    taxi_prediction_read_dataframe = PythonOperator(
        task_id='taxi_prediction_read_dataframe',
        python_callable=read_dataframe,
    )

    taxi_production_create_X = PythonOperator(
        task_id='taxi_production_create_X',
        python_callable=create_X,
    )

    taxi_production_train_model = PythonOperator(
        task_id='taxi_production_train_model',
        python_callable=train_model,
    )

    taxi_prediction_read_dataframe >> taxi_production_create_X >> taxi_production_train_model

