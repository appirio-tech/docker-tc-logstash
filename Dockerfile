FROM mantika/logstash-dynamodb-streams

#FROM anapsix/alpine-java

#COPY logstash-2.0.0-beta2.zip /data/
COPY logstash-filter-skills.zip /data/
COPY informix.jdbc-3.0.0.JC3.jar /data/

# Python
#RUN apk add --no-cache python curl && \
#    apk add --no-cache --virtual=build-dependencies wget ca-certificates && \
#    wget "https://bootstrap.pypa.io/get-pip.py" -O /dev/stdout | python && \
#    apk del build-dependencies

RUN apt-get update && apt-get install -y python2.7 && \
 wget "https://bootstrap.pypa.io/get-pip.py"
RUN /usr/bin/python2.7 get-pip.py

# install jinja2 cli 
RUN pip install j2cli

#RUN unzip /data/logstash-2.0.0-beta2.zip -d /opt/
#RUN mv /opt/logstash-2.0.0-beta2 /opt/logstash
RUN unzip /data/logstash-filter-skills.zip -d /data/

ENV PATH /opt/logstash/bin:$PATH
ENV PATH /opt/logstash/vendor/jruby/bin/:$PATH
RUN curl --create-dirs -sS -o /opt/logstash/vendor/jruby/lib/ruby/.mvn/extensions.xml https://raw.githubusercontent.com/takari/ruby-maven/master/.mvn/extensions.xml

# dynamodb plugin
WORKDIR /opt/logstash/
RUN echo 'gem "logstash-filter-skills", :path => "/data/logstash-filter-skills/"' >> Gemfile
RUN echo 'gem "logstash-filter-aggregate"' >> Gemfile
# add more gems here...

WORKDIR /

RUN plugin install --no-verify

RUN plugin list


#COPY docker-entrypoint.sh /

#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["logstash", "agent"]

