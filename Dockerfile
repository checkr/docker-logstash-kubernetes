FROM logstash:2.4

RUN logstash-plugin install logstash-output-elasticsearch && \
  logstash-plugin install logstash-filter-k8s && \
  logstash-plugin install logstash-input-journald && \
  logstash-plugin install logstash-output-cloudwatch

COPY conf.d/ /logstash/conf.d/
COPY run.sh /run.sh
WORKDIR /var/lib/logstash
VOLUME /var/lib/logstash

CMD ["/run.sh"]
