#!/bin/bash

export HOME=/var/lib/logstash

: ${LS_HEAP_SIZE:=500m}
: ${LS_JAVA_OPTS:=-Djava.io.tmpdir=${HOME}}
: ${LS_LOG_DIR:=/var/lib/logstash}
: ${LS_OPEN_FILES:=8192}

: ${INPUT_JOURNALD:=true}

: ${OUTPUT_CLOUDWATCH:=false}
: ${AWS_REGION:=eu-west-1}
: ${LOG_GROUP_NAME:=logstash}
: ${LOG_STREAM_NAME:=$(hostname)}

: ${OUTPUT_ELASTICSEARCH:=true}
: ${ELASTICSEARCH_HOST:=127.0.0.1:9200}
: ${ELASTICSEARCH_SSL:=true}
: ${ELASTICSEARCH_INDEX_SUFFIX:=""}
: ${ELASTICSEARCH_USER:=""}
: ${ELASTICSEARCH_PASSWORD:=""}

if [[ ${INPUT_JOURNALD} != 'true' ]]; then
  rm -f /logstash/conf.d/10_input_journald.conf
fi

if [[ ${OUTPUT_ELASTICSEARCH} != 'true' ]]; then
  rm -f /logstash/conf.d/20_output_journald_elasticsearch.conf
  rm -f /logstash/conf.d/20_output_kubernetes_elasticsearch.conf
else
  sed -e "s/%ELASTICSEARCH_HOST%/${ELASTICSEARCH_HOST}/g" \
      -i /logstash/conf.d/20_output_kubernetes_elasticsearch.conf \
      -i /logstash/conf.d/20_output_journald_elasticsearch.conf

  sed -e "s/%ELASTICSEARCH_INDEX_SUFFIX%/${ELASTICSEARCH_INDEX_SUFFIX}/g" \
      -i /logstash/conf.d/20_output_kubernetes_elasticsearch.conf \
      -i /logstash/conf.d/20_output_journald_elasticsearch.conf

  sed -e "s/%ELASTICSEARCH_SSL%/${ELASTICSEARCH_SSL}/g" \
      -i /logstash/conf.d/20_output_kubernetes_elasticsearch.conf \
      -i /logstash/conf.d/20_output_journald_elasticsearch.conf

  sed -e "s/%ELASTICSEARCH_USER%/${ELASTICSEARCH_USER}/g" \
      -i /logstash/conf.d/20_output_kubernetes_elasticsearch.conf \
      -i /logstash/conf.d/20_output_journald_elasticsearch.conf

  sed -e "s/%ELASTICSEARCH_PASSWORD%/${ELASTICSEARCH_PASSWORD}/g" \
      -i /logstash/conf.d/20_output_kubernetes_elasticsearch.conf \
      -i /logstash/conf.d/20_output_journald_elasticsearch.conf
fi

if [[ ${OUTPUT_CLOUDWATCH} != 'true' ]]; then
  rm -f /logstash/conf.d/20_output_kubernetes_cloudwatch.conf
  rm -f /logstash/conf.d/20_output_journald_cloudwatch.conf
else
  sed -e "s/%AWS_REGION%/${AWS_REGION}/g" \
      -e "s/%LOG_GROUP_NAME%/${LOG_GROUP_NAME}/g" \
      -e "s/%LOG_STREAM_NAME%/${LOG_STREAM_NAME}/g" \
      -i /logstash/conf.d/20_output_kubernetes_cloudwatch.conf \
      -i /logstash/conf.d/20_output_journald_cloudwatch.conf
fi

ulimit -n ${LS_OPEN_FILES} > /dev/null

echo "Starting logstash"
exec logstash -f /logstash/conf.d ${LOGSTASH_ARGS}
