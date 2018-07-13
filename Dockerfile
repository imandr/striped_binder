FROM centos:7

RUN curl https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo && \
	yum install -y epel-release && \
	yum upgrade -y && \
	yum groupinstall -y 'Development Tools' && \
	yum install -y \
		sudo \
		git \
		wget \
		tmux \
		sbt \
		python-pip \
		python-devel && \
	yum clean all && rm -rf /var/cache/yum

RUN pip install --upgrade pip && \
	pip install numpy jupyter vega pandas notebook

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser \
    --comment "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER ${NB_USER}

# histbook
RUN cd ${HOME} && \
	git clone https://github.com/scikit-hep/histbook.git && \
	cd histbook && \
	git checkout issue-37 && \
	python setup.py install --user

# striped server client
RUN cd ${HOME} && \
	git clone http://cdcvs.fnal.gov/projects/nosql-ldrd striped && \
	cd striped/package && \
	python setup.py install --user

RUN cd ${HOME}

COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
