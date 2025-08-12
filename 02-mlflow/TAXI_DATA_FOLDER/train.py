import os
import pickle
import click
import mlflow
from mlflow.models.signature import infer_signature

from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import root_mean_squared_error

mlflow.set_tracking_uri("http://127.0.0.1:5000/")

def load_pickle(filename: str):
    with open(filename, "rb") as f_in:
        return pickle.load(f_in)


mlflow.set_experiment("homework_experiment_1")
#mlflow.sklearn.autolog()

@click.command()
@click.option(
    "--data_path",
    default="/workspaces/mlops-zoomcamp/02-mlflow/TAXI_DATA_FOLDER/output",
    help="Location where the processed NYC taxi trip data was saved"
)

def run_train(data_path: str):

    X_train, y_train = load_pickle(os.path.join(data_path, "train.pkl"))
    X_val, y_val = load_pickle(os.path.join(data_path, "val.pkl"))

    with mlflow.start_run():
        rf = RandomForestRegressor(max_depth=10, random_state=0)
        rf.fit(X_train, y_train)
        y_pred = rf.predict(X_val)

        rmse = root_mean_squared_error(y_val, y_pred)
        mlflow.log_param("max_depth", 10)
        mlflow.log_param("random_state", 0)
        mlflow.log_metric("rmse", rmse)

        signature = infer_signature(X_train, y_pred)
        mlflow.sklearn.log_model(rf, name="model", signature=signature, input_example=X_train[:2].toarray()) # signature -> hint how data should be (using infer_ for exact format)

 

if __name__ == '__main__': # Protection standard pour que run_train() se lance que si on execute ce scrypt train.py pas ailleurs
    run_train()
    print("Run terminé")