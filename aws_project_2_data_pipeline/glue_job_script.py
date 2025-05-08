
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

datasource = glueContext.create_dynamic_frame.from_catalog(
    database="your_database_name",
    table_name="your_table_name",
    transformation_ctx="datasource"
)

transformed = ApplyMapping.apply(frame=datasource,
                                 mappings=[
                                     ("sensor_id", "string", "sensor_id", "string"),
                                     ("timestamp", "string", "timestamp", "timestamp"),
                                     ("temperature", "double", "temperature", "double"),
                                     ("humidity", "double", "humidity", "double")
                                 ],
                                 transformation_ctx="transformed")

glueContext.write_dynamic_frame.from_options(
    frame=transformed,
    connection_type="s3",
    connection_options={"path": "s3://your-final-bucket-name/"},
    format="csv",
    transformation_ctx="datasink"
)

job.commit()
