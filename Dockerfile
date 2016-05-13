FROM mantika/logstash-dynamodb-streams

ADD jar/jdbc /opt/logstash/vendor/

# Copying to old location to maintain backward compatibility
COPY jar/jdbc/informix.jdbc-3.0.0.JC3.jar /
COPY jar/jdbc/ifxjdbc.jar /

COPY logstash-filter-skills.zip /data/

# Python
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
RUN echo 'gem "logstash-filter-jdbc"' >> Gemfile
RUN echo 'gem "logstash-filter-aggregate"' >> Gemfile
RUN echo 'gem "logstash-output-amazon_es"' >> Gemfile
RUN echo 'gem "logstash-output-jdbc"' >> Gemfile

# add more gems here...

WORKDIR /data

RUN logstash-plugin install --no-verify

RUN logstash-plugin list


WORKDIR /
