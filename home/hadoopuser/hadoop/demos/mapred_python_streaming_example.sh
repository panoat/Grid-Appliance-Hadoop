#!/bin/sh

echo ""
echo "--- Copying Python map/reduce scripts to worker nodes"
echo ""

$HADOOP_HOME/bin/scppush.sh $HADOOP_HOME/demos/mapper.py
$HADOOP_HOME/bin/scppush.sh $HADOOP_HOME/demos/reducer.py

echo ""
echo "--- Copying test input file into HDFS"
echo ""

$HADOOP_HOME/bin/hadoop dfs -copyFromLocal $HADOOP_HOME/demos/demoinputs demoinputs

echo ""
echo "--- Running map-reduce job"
echo ""

$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/contrib/streaming/hadoop-0.20.1-streaming.jar -mapper $HADOOP_HOME/demos/mapper.py -reducer $HADOOP_HOME/demos/reducer.py -input demoinputs -output demooutputs

echo ""
echo "--- Showing contents of result directory in HDFS"
echo ""

$HADOOP_HOME/bin/hadoop dfs -cat demooutputs/*
