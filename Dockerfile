FROM logstash:2.4.1


# Make .m2 accessible to logstash user, otherwise logstash won't start
RUN mkdir -p /var/lib/logstash/.m2
RUN ln -s /var/lib/logstash/.m2 /root/.m2

ENV PATH /opt/logstash/vendor/jruby/bin/:$PATH
RUN gem install logstash-input-dynamodb:'> 2' logstash-filter-dynamodb:'> 2'
RUN plugin install logstash-input-dynamodb logstash-filter-dynamodb


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
