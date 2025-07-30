PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE experiments (
	experiment_id INTEGER NOT NULL, 
	name VARCHAR(256) NOT NULL, 
	artifact_location VARCHAR(256), 
	lifecycle_stage VARCHAR(32), creation_time BIGINT, last_update_time BIGINT, 
	CONSTRAINT experiment_pk PRIMARY KEY (experiment_id), 
	CONSTRAINT experiments_lifecycle_stage CHECK (lifecycle_stage IN ('active', 'deleted')), 
	UNIQUE (name)
);
INSERT INTO experiments VALUES(0,'Default','mlflow-artifacts:/0','active',1753274678617,1753274678617);
INSERT INTO experiments VALUES(1,'nyc-taxi-experiment','/workspaces/mlops-zoomcamp/02-mlflow/mlruns/1','active',1753288455615,1753288455615);
INSERT INTO experiments VALUES(2,'nyc-taxi-experiments','/workspaces/mlops-zoomcamp/02-mlflow/mlruns/2','deleted',1753288855507,1753350875639);
CREATE TABLE alembic_version (
	version_num VARCHAR(32) NOT NULL, 
	CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);
INSERT INTO alembic_version VALUES('bda7b8c39065');
CREATE TABLE experiment_tags (
	"key" VARCHAR(250) NOT NULL, 
	value VARCHAR(5000), 
	experiment_id INTEGER NOT NULL, 
	CONSTRAINT experiment_tag_pk PRIMARY KEY ("key", experiment_id), 
	FOREIGN KEY(experiment_id) REFERENCES experiments (experiment_id)
);
CREATE TABLE registered_models (
	name VARCHAR(256) NOT NULL, 
	creation_time BIGINT, 
	last_updated_time BIGINT, 
	description VARCHAR(5000), 
	CONSTRAINT registered_model_pk PRIMARY KEY (name), 
	UNIQUE (name)
);
CREATE TABLE IF NOT EXISTS "runs" (
	run_uuid VARCHAR(32) NOT NULL, 
	name VARCHAR(250), 
	source_type VARCHAR(20), 
	source_name VARCHAR(500), 
	entry_point_name VARCHAR(50), 
	user_id VARCHAR(256), 
	status VARCHAR(9), 
	start_time BIGINT, 
	end_time BIGINT, 
	source_version VARCHAR(50), 
	lifecycle_stage VARCHAR(20), 
	artifact_uri VARCHAR(200), 
	experiment_id INTEGER, deleted_time BIGINT, 
	CONSTRAINT run_pk PRIMARY KEY (run_uuid), 
	CONSTRAINT runs_lifecycle_stage CHECK (lifecycle_stage IN ('active', 'deleted')), 
	CONSTRAINT source_type CHECK (source_type IN ('NOTEBOOK', 'JOB', 'LOCAL', 'UNKNOWN', 'PROJECT')), 
	FOREIGN KEY(experiment_id) REFERENCES experiments (experiment_id), 
	CHECK (status IN ('SCHEDULED', 'FAILED', 'FINISHED', 'RUNNING', 'KILLED'))
);
INSERT INTO runs VALUES('f287eabc7f724b90a0ba7edaf785b0cb','big-shoat-199','UNKNOWN','','','codespace','FINISHED',1753288703886,1753288703938,'','active','/workspaces/mlops-zoomcamp/02-mlflow/mlruns/1/f287eabc7f724b90a0ba7edaf785b0cb/artifacts',1,NULL);
INSERT INTO runs VALUES('5d6adc98938a4633ac4768fa668d56bf','wise-ram-717','UNKNOWN','','','codespace','FINISHED',1753290115065,1753290115095,'','deleted','/workspaces/mlops-zoomcamp/02-mlflow/mlruns/2/5d6adc98938a4633ac4768fa668d56bf/artifacts',2,1753350875644);
INSERT INTO runs VALUES('375a5aecba744c649a7bc5de0891d347','welcoming-crow-588','UNKNOWN','','','codespace','FAILED',1753354344171,1753354349255,'','active','/workspaces/mlops-zoomcamp/02-mlflow/mlruns/1/375a5aecba744c649a7bc5de0891d347/artifacts',1,NULL);
INSERT INTO runs VALUES('c82d54e411874c4696830725000576c5','bedecked-wren-298','UNKNOWN','','','codespace','FINISHED',1753354386818,1753354392051,'','active','/workspaces/mlops-zoomcamp/02-mlflow/mlruns/1/c82d54e411874c4696830725000576c5/artifacts',1,NULL);
INSERT INTO runs VALUES('8e688e3003c34820a51016c6968ff6a4','defiant-yak-683','UNKNOWN','','','codespace','FINISHED',1753354852578,1753354857715,'','active','/workspaces/mlops-zoomcamp/02-mlflow/mlruns/1/8e688e3003c34820a51016c6968ff6a4/artifacts',1,NULL);
INSERT INTO runs VALUES('e8c2d6700c424c478dd7f21dff629b77','masked-pig-273','UNKNOWN','','','codespace','FINISHED',1753359836303,1753359841656,'','active','/workspaces/mlops-zoomcamp/02-mlflow/mlruns/1/e8c2d6700c424c478dd7f21dff629b77/artifacts',1,NULL);
CREATE TABLE registered_model_tags (
	"key" VARCHAR(250) NOT NULL, 
	value VARCHAR(5000), 
	name VARCHAR(256) NOT NULL, 
	CONSTRAINT registered_model_tag_pk PRIMARY KEY ("key", name), 
	FOREIGN KEY(name) REFERENCES registered_models (name) ON UPDATE cascade
);
CREATE TABLE IF NOT EXISTS "model_versions" (
	name VARCHAR(256) NOT NULL, 
	version INTEGER NOT NULL, 
	creation_time BIGINT, 
	last_updated_time BIGINT, 
	description VARCHAR(5000), 
	user_id VARCHAR(256), 
	current_stage VARCHAR(20), 
	source VARCHAR(500), 
	run_id VARCHAR(32), 
	status VARCHAR(20), 
	status_message VARCHAR(500), 
	run_link VARCHAR(500), storage_location VARCHAR(500), 
	CONSTRAINT model_version_pk PRIMARY KEY (name, version), 
	FOREIGN KEY(name) REFERENCES registered_models (name) ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS "latest_metrics" (
	"key" VARCHAR(250) NOT NULL, 
	value FLOAT NOT NULL, 
	timestamp BIGINT, 
	step BIGINT NOT NULL, 
	is_nan BOOLEAN NOT NULL, 
	run_uuid VARCHAR(32) NOT NULL, 
	CONSTRAINT latest_metric_pk PRIMARY KEY ("key", run_uuid), 
	FOREIGN KEY(run_uuid) REFERENCES runs (run_uuid), 
	CHECK (is_nan IN (0, 1))
);
INSERT INTO latest_metrics VALUES('ma_metric',0.949999999999999956,1753288703926,0,0,'f287eabc7f724b90a0ba7edaf785b0cb');
INSERT INTO latest_metrics VALUES('rmse',2.529999999999999805,1753290115085,0,0,'5d6adc98938a4633ac4768fa668d56bf');
INSERT INTO latest_metrics VALUES('rmse',53.15298877818079149,1753354392001,0,0,'c82d54e411874c4696830725000576c5');
INSERT INTO latest_metrics VALUES('rmse',53.15298877818079149,1753354857689,0,0,'8e688e3003c34820a51016c6968ff6a4');
INSERT INTO latest_metrics VALUES('rmse',53.42052823929909521,1753359841565,0,0,'e8c2d6700c424c478dd7f21dff629b77');
CREATE TABLE IF NOT EXISTS "metrics" (
	"key" VARCHAR(250) NOT NULL, 
	value FLOAT NOT NULL, 
	timestamp BIGINT NOT NULL, 
	run_uuid VARCHAR(32) NOT NULL, 
	step BIGINT DEFAULT '0' NOT NULL, 
	is_nan BOOLEAN DEFAULT '0' NOT NULL, 
	CONSTRAINT metric_pk PRIMARY KEY ("key", timestamp, step, run_uuid, value, is_nan), 
	FOREIGN KEY(run_uuid) REFERENCES runs (run_uuid), 
	CHECK (is_nan IN (0, 1))
);
INSERT INTO metrics VALUES('ma_metric',0.949999999999999956,1753288703926,'f287eabc7f724b90a0ba7edaf785b0cb',0,0);
INSERT INTO metrics VALUES('rmse',2.529999999999999805,1753290115085,'5d6adc98938a4633ac4768fa668d56bf',0,0);
INSERT INTO metrics VALUES('rmse',53.15298877818079149,1753354392001,'c82d54e411874c4696830725000576c5',0,0);
INSERT INTO metrics VALUES('rmse',53.15298877818079149,1753354857689,'8e688e3003c34820a51016c6968ff6a4',0,0);
INSERT INTO metrics VALUES('rmse',53.42052823929909521,1753359841565,'e8c2d6700c424c478dd7f21dff629b77',0,0);
CREATE TABLE registered_model_aliases (
	alias VARCHAR(256) NOT NULL, 
	version INTEGER NOT NULL, 
	name VARCHAR(256) NOT NULL, 
	CONSTRAINT registered_model_alias_pk PRIMARY KEY (name, alias), 
	CONSTRAINT registered_model_alias_name_fkey FOREIGN KEY(name) REFERENCES registered_models (name) ON DELETE cascade ON UPDATE cascade
);
CREATE TABLE inputs (
	input_uuid VARCHAR(36) NOT NULL, 
	source_type VARCHAR(36) NOT NULL, 
	source_id VARCHAR(36) NOT NULL, 
	destination_type VARCHAR(36) NOT NULL, 
	destination_id VARCHAR(36) NOT NULL, step BIGINT DEFAULT '0' NOT NULL, 
	CONSTRAINT inputs_pk PRIMARY KEY (source_type, source_id, destination_type, destination_id)
);
CREATE TABLE input_tags (
	input_uuid VARCHAR(36) NOT NULL, 
	name VARCHAR(255) NOT NULL, 
	value VARCHAR(500) NOT NULL, 
	CONSTRAINT input_tags_pk PRIMARY KEY (input_uuid, name)
);
CREATE TABLE IF NOT EXISTS "params" (
	"key" VARCHAR(250) NOT NULL, 
	value VARCHAR(8000) NOT NULL, 
	run_uuid VARCHAR(32) NOT NULL, 
	CONSTRAINT param_pk PRIMARY KEY ("key", run_uuid), 
	FOREIGN KEY(run_uuid) REFERENCES runs (run_uuid)
);
INSERT INTO params VALUES('param1','42','f287eabc7f724b90a0ba7edaf785b0cb');
INSERT INTO params VALUES('model','xgboost','5d6adc98938a4633ac4768fa668d56bf');
INSERT INTO params VALUES('train-data-path','./data/green_tripdata_2021-01.csv','375a5aecba744c649a7bc5de0891d347');
INSERT INTO params VALUES('valid-data-path','./data/green_tripdata_2021-02.csv','375a5aecba744c649a7bc5de0891d347');
INSERT INTO params VALUES('alpha','0.1','375a5aecba744c649a7bc5de0891d347');
INSERT INTO params VALUES('train-data-path','./data/green_tripdata_2021-01.csv','c82d54e411874c4696830725000576c5');
INSERT INTO params VALUES('valid-data-path','./data/green_tripdata_2021-02.csv','c82d54e411874c4696830725000576c5');
INSERT INTO params VALUES('alpha','0.1','c82d54e411874c4696830725000576c5');
INSERT INTO params VALUES('train-data-path','/workspaces/mlops-zoomcamp/02-mlflow/data/green_tripdata_2021-01.parquet','8e688e3003c34820a51016c6968ff6a4');
INSERT INTO params VALUES('valid-data-path','/workspaces/mlops-zoomcamp/02-mlflow/data/green_tripdata_2021-02.parquet','8e688e3003c34820a51016c6968ff6a4');
INSERT INTO params VALUES('alpha','0.1','8e688e3003c34820a51016c6968ff6a4');
INSERT INTO params VALUES('train-data-path','/workspaces/mlops-zoomcamp/02-mlflow/data/green_tripdata_2021-01.parquet','e8c2d6700c424c478dd7f21dff629b77');
INSERT INTO params VALUES('valid-data-path','/workspaces/mlops-zoomcamp/02-mlflow/data/green_tripdata_2021-02.parquet','e8c2d6700c424c478dd7f21dff629b77');
INSERT INTO params VALUES('alpha','0.01','e8c2d6700c424c478dd7f21dff629b77');
CREATE TABLE trace_info (
	request_id VARCHAR(50) NOT NULL, 
	experiment_id INTEGER NOT NULL, 
	timestamp_ms BIGINT NOT NULL, 
	execution_time_ms BIGINT, 
	status VARCHAR(50) NOT NULL, 
	CONSTRAINT trace_info_pk PRIMARY KEY (request_id), 
	CONSTRAINT fk_trace_info_experiment_id FOREIGN KEY(experiment_id) REFERENCES experiments (experiment_id)
);
CREATE TABLE IF NOT EXISTS "trace_tags" (
	"key" VARCHAR(250) NOT NULL, 
	value VARCHAR(8000), 
	request_id VARCHAR(50) NOT NULL, 
	CONSTRAINT trace_tag_pk PRIMARY KEY ("key", request_id), 
	CONSTRAINT fk_trace_tags_request_id FOREIGN KEY(request_id) REFERENCES trace_info (request_id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "trace_request_metadata" (
	"key" VARCHAR(250) NOT NULL, 
	value VARCHAR(8000), 
	request_id VARCHAR(50) NOT NULL, 
	CONSTRAINT trace_request_metadata_pk PRIMARY KEY ("key", request_id), 
	CONSTRAINT fk_trace_request_metadata_request_id FOREIGN KEY(request_id) REFERENCES trace_info (request_id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "tags" (
	"key" VARCHAR(250) NOT NULL, 
	value VARCHAR(8000), 
	run_uuid VARCHAR(32) NOT NULL, 
	CONSTRAINT tag_pk PRIMARY KEY ("key", run_uuid), 
	FOREIGN KEY(run_uuid) REFERENCES runs (run_uuid)
);
INSERT INTO tags VALUES('mlflow.user','codespace','f287eabc7f724b90a0ba7edaf785b0cb');
INSERT INTO tags VALUES('mlflow.source.name','/home/codespace/anaconda3/envs/exp-tracking-env/lib/python3.9/site-packages/ipykernel_launcher.py','f287eabc7f724b90a0ba7edaf785b0cb');
INSERT INTO tags VALUES('mlflow.source.type','LOCAL','f287eabc7f724b90a0ba7edaf785b0cb');
INSERT INTO tags VALUES('mlflow.runName','big-shoat-199','f287eabc7f724b90a0ba7edaf785b0cb');
INSERT INTO tags VALUES('mlflow.user','codespace','5d6adc98938a4633ac4768fa668d56bf');
INSERT INTO tags VALUES('mlflow.source.name','/home/codespace/anaconda3/envs/exp-tracking-env/lib/python3.9/site-packages/ipykernel_launcher.py','5d6adc98938a4633ac4768fa668d56bf');
INSERT INTO tags VALUES('mlflow.source.type','LOCAL','5d6adc98938a4633ac4768fa668d56bf');
INSERT INTO tags VALUES('mlflow.runName','wise-ram-717','5d6adc98938a4633ac4768fa668d56bf');
INSERT INTO tags VALUES('mlflow.user','codespace','375a5aecba744c649a7bc5de0891d347');
INSERT INTO tags VALUES('mlflow.source.name','/home/codespace/anaconda3/envs/exp-tracking-env/lib/python3.9/site-packages/ipykernel_launcher.py','375a5aecba744c649a7bc5de0891d347');
INSERT INTO tags VALUES('mlflow.source.type','LOCAL','375a5aecba744c649a7bc5de0891d347');
INSERT INTO tags VALUES('mlflow.runName','welcoming-crow-588','375a5aecba744c649a7bc5de0891d347');
INSERT INTO tags VALUES('developer','cristian','375a5aecba744c649a7bc5de0891d347');
INSERT INTO tags VALUES('mlflow.user','codespace','c82d54e411874c4696830725000576c5');
INSERT INTO tags VALUES('mlflow.source.name','/home/codespace/anaconda3/envs/exp-tracking-env/lib/python3.9/site-packages/ipykernel_launcher.py','c82d54e411874c4696830725000576c5');
INSERT INTO tags VALUES('mlflow.source.type','LOCAL','c82d54e411874c4696830725000576c5');
INSERT INTO tags VALUES('mlflow.runName','bedecked-wren-298','c82d54e411874c4696830725000576c5');
INSERT INTO tags VALUES('developer','cristian','c82d54e411874c4696830725000576c5');
INSERT INTO tags VALUES('mlflow.user','codespace','8e688e3003c34820a51016c6968ff6a4');
INSERT INTO tags VALUES('mlflow.source.name','/home/codespace/anaconda3/envs/exp-tracking-env/lib/python3.9/site-packages/ipykernel_launcher.py','8e688e3003c34820a51016c6968ff6a4');
INSERT INTO tags VALUES('mlflow.source.type','LOCAL','8e688e3003c34820a51016c6968ff6a4');
INSERT INTO tags VALUES('mlflow.runName','defiant-yak-683','8e688e3003c34820a51016c6968ff6a4');
INSERT INTO tags VALUES('developer','manza','8e688e3003c34820a51016c6968ff6a4');
INSERT INTO tags VALUES('mlflow.user','codespace','e8c2d6700c424c478dd7f21dff629b77');
INSERT INTO tags VALUES('mlflow.source.name','/home/codespace/anaconda3/envs/exp-tracking-env/lib/python3.9/site-packages/ipykernel_launcher.py','e8c2d6700c424c478dd7f21dff629b77');
INSERT INTO tags VALUES('mlflow.source.type','LOCAL','e8c2d6700c424c478dd7f21dff629b77');
INSERT INTO tags VALUES('mlflow.runName','masked-pig-273','e8c2d6700c424c478dd7f21dff629b77');
INSERT INTO tags VALUES('developer','manza','e8c2d6700c424c478dd7f21dff629b77');
CREATE TABLE IF NOT EXISTS "datasets" (
	dataset_uuid VARCHAR(36) NOT NULL, 
	experiment_id INTEGER NOT NULL, 
	name VARCHAR(500) NOT NULL, 
	digest VARCHAR(36) NOT NULL, 
	dataset_source_type VARCHAR(36) NOT NULL, 
	dataset_source TEXT NOT NULL, 
	dataset_schema TEXT, 
	dataset_profile TEXT, 
	CONSTRAINT dataset_pk PRIMARY KEY (experiment_id, name, digest), 
	CONSTRAINT fk_datasets_experiment_id_experiments FOREIGN KEY(experiment_id) REFERENCES experiments (experiment_id) ON DELETE CASCADE
);
CREATE TABLE logged_models (
	model_id VARCHAR(36) NOT NULL, 
	experiment_id INTEGER NOT NULL, 
	name VARCHAR(500) NOT NULL, 
	artifact_location VARCHAR(1000) NOT NULL, 
	creation_timestamp_ms BIGINT NOT NULL, 
	last_updated_timestamp_ms BIGINT NOT NULL, 
	status INTEGER NOT NULL, 
	lifecycle_stage VARCHAR(32), 
	model_type VARCHAR(500), 
	source_run_id VARCHAR(32), 
	status_message VARCHAR(1000), 
	CONSTRAINT logged_models_pk PRIMARY KEY (model_id), 
	CONSTRAINT logged_models_lifecycle_stage_check CHECK (lifecycle_stage IN ('active', 'deleted')), 
	CONSTRAINT fk_logged_models_experiment_id FOREIGN KEY(experiment_id) REFERENCES experiments (experiment_id) ON DELETE CASCADE
);
CREATE TABLE logged_model_metrics (
	model_id VARCHAR(36) NOT NULL, 
	metric_name VARCHAR(500) NOT NULL, 
	metric_timestamp_ms BIGINT NOT NULL, 
	metric_step BIGINT NOT NULL, 
	metric_value FLOAT, 
	experiment_id INTEGER NOT NULL, 
	run_id VARCHAR(32) NOT NULL, 
	dataset_uuid VARCHAR(36), 
	dataset_name VARCHAR(500), 
	dataset_digest VARCHAR(36), 
	CONSTRAINT logged_model_metrics_pk PRIMARY KEY (model_id, metric_name, metric_timestamp_ms, metric_step, run_id), 
	CONSTRAINT fk_logged_model_metrics_experiment_id FOREIGN KEY(experiment_id) REFERENCES experiments (experiment_id), 
	CONSTRAINT fk_logged_model_metrics_model_id FOREIGN KEY(model_id) REFERENCES logged_models (model_id) ON DELETE CASCADE, 
	CONSTRAINT fk_logged_model_metrics_run_id FOREIGN KEY(run_id) REFERENCES runs (run_uuid) ON DELETE CASCADE
);
CREATE TABLE logged_model_params (
	model_id VARCHAR(36) NOT NULL, 
	experiment_id INTEGER NOT NULL, 
	param_key VARCHAR(255) NOT NULL, 
	param_value TEXT NOT NULL, 
	CONSTRAINT logged_model_params_pk PRIMARY KEY (model_id, param_key), 
	CONSTRAINT fk_logged_model_params_experiment_id FOREIGN KEY(experiment_id) REFERENCES experiments (experiment_id), 
	CONSTRAINT fk_logged_model_params_model_id FOREIGN KEY(model_id) REFERENCES logged_models (model_id) ON DELETE CASCADE
);
CREATE TABLE logged_model_tags (
	model_id VARCHAR(36) NOT NULL, 
	experiment_id INTEGER NOT NULL, 
	tag_key VARCHAR(255) NOT NULL, 
	tag_value TEXT NOT NULL, 
	CONSTRAINT logged_model_tags_pk PRIMARY KEY (model_id, tag_key), 
	CONSTRAINT fk_logged_model_tags_experiment_id FOREIGN KEY(experiment_id) REFERENCES experiments (experiment_id), 
	CONSTRAINT fk_logged_model_tags_model_id FOREIGN KEY(model_id) REFERENCES logged_models (model_id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "model_version_tags" (
	"key" VARCHAR(250) NOT NULL, 
	value TEXT, 
	name VARCHAR(256) NOT NULL, 
	version INTEGER NOT NULL, 
	CONSTRAINT model_version_tag_pk PRIMARY KEY ("key", name, version), 
	FOREIGN KEY(name, version) REFERENCES model_versions (name, version) ON UPDATE CASCADE
);
CREATE INDEX index_metrics_run_uuid ON metrics (run_uuid);
CREATE INDEX index_latest_metrics_run_uuid ON latest_metrics (run_uuid);
CREATE INDEX index_inputs_destination_type_destination_id_source_type ON inputs (destination_type, destination_id, source_type);
CREATE INDEX index_inputs_input_uuid ON inputs (input_uuid);
CREATE INDEX index_params_run_uuid ON params (run_uuid);
CREATE INDEX index_trace_info_experiment_id_timestamp_ms ON trace_info (experiment_id, timestamp_ms);
CREATE INDEX index_trace_tags_request_id ON trace_tags (request_id);
CREATE INDEX index_trace_request_metadata_request_id ON trace_request_metadata (request_id);
CREATE INDEX index_tags_run_uuid ON tags (run_uuid);
CREATE INDEX index_datasets_dataset_uuid ON datasets (dataset_uuid);
CREATE INDEX index_datasets_experiment_id_dataset_source_type ON datasets (experiment_id, dataset_source_type);
CREATE INDEX index_logged_model_metrics_model_id ON logged_model_metrics (model_id);
COMMIT;
