import os
import pickle
import click
import pandas as pd
from sklearn.feature_extraction import DictVectorizer

def dump_pickle(obj, filename: str):
    with open(filename, "wb") as f_out:
        return pickle.dump(obj, f_out)

def read_dataframe(filename: str):
    df = pd.read_parquet(filename)
    df['duration'] = df['lpep_dropoff_datetime'] - df['lpep_pickup_datetime']
    df.duration = df.duration.apply(lambda td: td.total_seconds() / 60) # shortcut for applying the function lambda to all of column duration
    df = df[(df.duration >= 1) & (df.duration <= 60)]
    
    categorical = ['PULocationID', 'DOLocationID'] # Convertir les colonnes catégorielles (PULocationID, DOLocationID) 
    df[categorical] = df[categorical].astype(str) # en chaînes de caractères
    return df

def preprocess(df: pd.DataFrame, dv: DictVectorizer, fit_dv: bool = False):
    df['PU_DO'] = df['PULocationID'] + '_' + df['DOLocationID']
    categorical = ['PU_DO']
    numerical = ['trip_distance']
    dicts = df[categorical + numerical].to_dict(orient='records') # Transform the columns into a dict cause DictVectorizer de scikit-learn prend en entrée ce format exact.
    if fit_dv:
        X = dv.fit_transform(dicts)
    else:
        X = dv.transform(dicts)
    return X, dv

@click.command()
@click.option(
    "--raw_data_path",
    default="/workspaces/mlops-zoomcamp/02-mlflow/TAXI_DATA_FOLDER", 
    help="Location where the raw NYC taxi trip data was saved"
)
@click.option(
    "--dest_path",
    default="/workspaces/mlops-zoomcamp/02-mlflow/TAXI_DATA_FOLDER/output",  
    help="Location where the resulting files will be saved"
)
def run_data_prep(raw_data_path: str, dest_path: str, dataset: str = "green"):
    # Verify the path exists
    if not os.path.exists(raw_data_path):
        raise FileNotFoundError(f"Data directory not found: {raw_data_path}")
    
    print(f"Looking for data in: {raw_data_path}")
    print(f"Files found: {os.listdir(raw_data_path)}")
    
    # Load parquet files
    df_train = read_dataframe(
        os.path.join(raw_data_path, f"{dataset}_tripdata_2023-01.parquet")
    )
    df_val = read_dataframe(
        os.path.join(raw_data_path, f"{dataset}_tripdata_2023-02.parquet")
    )
    df_test = read_dataframe(
        os.path.join(raw_data_path, f"{dataset}_tripdata_2023-03.parquet")
    )

    # Rest of the processing remains the same
    target = 'duration'
    y_train = df_train[target].values
    y_val = df_val[target].values
    y_test = df_test[target].values

    dv = DictVectorizer()
    X_train, dv = preprocess(df_train, dv, fit_dv=True)
    X_val, _ = preprocess(df_val, dv, fit_dv=False)
    X_test, _ = preprocess(df_test, dv, fit_dv=False)

    os.makedirs(dest_path, exist_ok=True)

    dump_pickle(dv, os.path.join(dest_path, "dv.pkl"))
    dump_pickle((X_train, y_train), os.path.join(dest_path, "train.pkl"))
    dump_pickle((X_val, y_val), os.path.join(dest_path, "val.pkl"))
    dump_pickle((X_test, y_test), os.path.join(dest_path, "test.pkl"))

if __name__ == '__main__':
    run_data_prep()