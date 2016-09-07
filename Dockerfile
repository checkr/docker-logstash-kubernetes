FROM logstash

RUN logstash-plugin install logstash-output-elasticsearch && \
  logstash-plugin install logstash-filter-kubernetes && \
  logstash-plugin install logstash-input-journald && \
  logstash-plugin install logstash-output-cloudwatch

COPY conf.d/ /logstash/conf.d/
WORKDIR /var/lib/logstash
VOLUME /var/lib/logstash

CMD ["/run.sh"]
