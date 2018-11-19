# | This Dockerfile provides a starting point for a ROCm installation of hipCaffe.
#FROM sabreshao/paddle_manylinux_devel_centos7:latest
FROM centos:7.4.1708
MAINTAINER Sabre Shao <sabre.shao@amd.com>

RUN yum install -y epel-release

RUN yum install -y centos-release-scl

RUN yum install -y devtoolset-7 && yum clean packages
RUN yum install -y devtoolset-7-libatomic-devel devtoolset-7-elfutils-libelf-devel && yum clean packages

RUN yum install -y bridge-utils cmake cmake3 devscripts dkms doxygen \
    dpkg dpkg-dev dpkg-perl elfutils-libelf-devel expect file \
    gettext gcc-c++ libgcc glibc.i686 libcxx-devel ncurses \
    ncurses-base ncurses-libs numactl-devel numactl-libs libssh make \
    openssl openssl-libs openssh openssh-clients openssl-devel \
    pciutils pciutils-devel pciutils-libs \
    python python-pip python-devel python-yaml \
    pkgconfig pth qemu-kvm  re2c rpm  rpm-build subversion  wget \
    doxygen git git-svn vim kernel-devel-uname-r && yum clean packages

RUN yum install -y lapack-devel lapack bc bridge-utils protobuf-compiler protobuf-devel leveldb-devel snappy-devel hdf5-devel atlas-devel glog-devel \
    lmdb-devel opencv-devel fftw3-devel elfutils-devel gflags-devel \
    blas blas-devel lapack lapack-devel doxygen git git-svn boost boost-devel vim kernel-devel-uname-r && yum clean packages

RUN yum install -y sqlite-devel zlib-devel openssl-devel pcre-devel vim tk-devel tkinter libtool xz \
    wget curl bzip2 make git patch unzip bison yasm diffutils automake which file && \
    yum clean packages

RUN yum -y install zlib-devel bzip2-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel && yum clean packages
RUN yum -y install glibc-devel libstdc++-devel glib2-devel libX11-devel libXext-devel libXrender-devel  mesa-libGL-devel libICE-devel libSM-devel ncurses-devel && yum clean packages
RUN yum -y install ocl-icd patchelf && yum clean packages

RUN wget -O /opt/swig-2.0.12.tar.gz https://cytranet.dl.sourceforge.net/project/swig/swig/swig-2.0.12/swig-2.0.12.tar.gz && \
    cd /opt && tar xzf swig-2.0.12.tar.gz && cd /opt/swig-2.0.12 && ./configure && make && make install && cd /opt && rm swig-2.0.12.tar.gz

RUN cd /opt && wget -q --no-check-certificate https://github.com/google/protobuf/releases/download/v3.1.0/protobuf-cpp-3.1.0.tar.gz && \
    tar xzf protobuf-cpp-3.1.0.tar.gz && \
    cd protobuf-3.1.0 && ./configure && make -j4 && make install && cd .. && rm -f protobuf-cpp-3.1.0.tar.gz

RUN wget  -qO- http://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz | \
    tar -xz -C /usr/local && \
    mkdir /root/gopath && \
    mkdir /root/gopath/bin && \
    mkdir /root/gopath/src

ENV GOROOT=/usr/local/go GOPATH=/root/gopath
ENV PATH=${GOROOT}/bin:${GOPATH}/bin:${PATH}

RUN easy_install -U pip && \
    pip install -U wheel && \
    pip install -U docopt  sphinx==1.5.6 && \
    pip install sphinx-rtd-theme==0.1.9 recommonmark
#PyYAML

#RUN pip install -r /paddle/python/requirements.txt
RUN pip install 'requests==2.9.2' 'numpy>=1.12,<=1.14' 'protobuf==3.1' 'recordio>=0.1.0' \
    'matplotlib' 'rarfile' 'scipy>=0.19.0' 'Pillow' 'nltk>=3.2.2' 'graphviz' 'LinkChecker' 'six'

RUN pip install pre-commit 'ipython==5.3.0' && \
    pip install 'ipykernel==4.6.0' 'jupyter==1.0.0' && \
    pip install opencv-python

#For docstring checker
RUN pip install pylint pytest astroid isort LinkChecker

#COPY boost_1_58_0.tar.bz2 /root/boost_1_58_0.tar.bz2
RUN cd /root && wget http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.bz2
RUN cd /root && tar xvjf /root/boost_1_58_0.tar.bz2 && \
    cd /root/boost_1_58_0 && ./bootstrap.sh --prefix=/usr/local && ./b2 install && \
    cd /root && rm -rf /root/boost_1_58_0 && rm /root/boost_1_58_0.tar.bz2

RUN echo "export PATH=/opt/rh/devtoolset-7/root/usr/bin${PATH:+:${PATH}}" >> ~/.bashrc
RUN echo "export MANPATH=/opt/rh/devtoolset-7/root/usr/share/man:${MANPATH} " >> ~/.bashrc
RUN echo "export INFOPATH=/opt/rh/devtoolset-7/root/usr/share/info${INFOPATH:+:${INFOPATH}} " >> ~/.bashrc
RUN echo "export PCP_DIR=/opt/rh/devtoolset-7/root " >> ~/.bashrc
RUN echo "export PERL5LIB=/opt/rh/devtoolset-7/root//usr/lib64/perl5/vendor_perl:/opt/rh/devtoolset-7/root/usr/lib/perl5:/opt/rh/devtoolset-7/root//usr/share/perl5/ " >> ~/.bashrc
RUN echo "export LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root$rpmlibdir$rpmlibdir32${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} " >> ~/.bashrc
RUN echo "export PYTHONPATH=/opt/rh/devtoolset-7/root/usr/lib64/python$pythonvers/site-packages:/opt/rh/devtoolset-7/root/usr/lib/python$pythonvers/" >> ~/.bashrc
RUN echo "export LDFLAGS=\"-Wl,-rpath=/opt/rh/devtoolset-7/root/usr/lib64 -Wl,-rpath=/opt/rh/devtoolset-7/root/usr/lib\" " >> ~/.bashrc

RUN mkdir -p /opt/rocm/include && cd /opt/rocm/include && wget https://github.com/Melown/half/raw/master/half/half.hpp

RUN cd ~ && git clone https://github.com/RadeonOpenCompute/rocm-cmake.git && cd ~/rocm-cmake && \
    mkdir -p build && cd build && cmake .. && cmake --build . --target install

COPY rocm9_115/repo /var/lib/rocm/repo

RUN echo "[ROCm]" > /etc/yum.repos.d/rocm.repo
RUN echo "name=ROCm" >> /etc/yum.repos.d/rocm.repo
RUN echo "baseurl=file:///var/lib/rocm/repo" >> /etc/yum.repos.d/rocm.repo
RUN echo "enabled=1" >> /etc/yum.repos.d/rocm.repo
RUN echo "gpgcheck=0" >> /etc/yum.repos.d/rocm.repo

RUN yum install --disablerepo=/* --enablerepo=ROCm --nogpgcheck -y hsa-ext-rocr-dev hsakmt-roct-dev hsa-rocr-dev rocm-opencl rocm-opencl-devel rocm-utils \
    miopengemm rocblas hipblas miopen-hip rocrand  cxlactivitylogger Thrust && \
    yum clean packages

RUN echo "export MIOPEN_ENABLE_CACHE_CONV_CONFIG=1" >> ~/.bashrc
RUN echo "export LD_LIBRARY_PATH=/paddle/build/third_party/mkldnn/src/extern_mkldnn-build/src:/paddle/build/third_party/install/mklml/lib:/opt/rocm/lib:/opt/rocm/rccl/lib:/opt/rocm/hiprand/lib:/opt/rocm/rocrand/lib:/usr/lib:/usr/local/lib:/opt/rocm/hip/lib" >> ~/.bashrc

RUN rpm -e cmake && ln -s /usr/bin/cmake3 /usr/bin/cmake
RUN ln -s /opt/rocm/lib /opt/rocm/lib64
RUN ln -s /opt/rocm/hip/include/hip /opt/rocm/include/hip

RUN echo gfx900\ngfx906 > /opt/rocm/bin/target.lst

RUN cd ~ && git clone https://github.com/ROCmSoftwarePlatform/rccl.git

RUN cd /root/rccl/ && \
    cd src && PATH=/opt/rh/devtoolset-7/root/usr/bin${PATH:+:${PATH}} \
    make && make install 
#&& cp /opt/rocm/rccl/include/rccl/rccl.h /opt/rocm/rccl/include/

COPY patch_conv_cache.txt /root
#COPY 0001-Add-cache.patch /root
#COPY 0002-Add-group-conv-support.patch /root

ARG user
ARG pwd
RUN cd ~/ && git clone https://${user}:${pwd}@github.com/AMDComputeLibraries/MLOpen -b 1.6.x && cd ~/MLOpen && \
    git apply ../patch_conv_cache.txt && \
    mkdir -p build && cd build && \
    PATH=/opt/rh/devtoolset-7/root/usr/bin${PATH:+:${PATH}} CXX=/opt/rocm/hcc/bin/hcc cmake \
    -DMIOPEN_BACKEND=HIP -DCMAKE_PREFIX_PATH="/opt/rocm/hcc;/opt/rocm/hip" -DCMAKE_CXX_FLAGS="-isystem /usr/include/x86_64-linux-gnu/" -DBoost_INCLUDE_DIR=/usr/local/include -DBoost_LIBRARY_DIR_RELEASE=/usr/local/lib64 .. && \
    PATH=/opt/rh/devtoolset-7/root/usr/bin${PATH:+:${PATH}} make -j && make package && \
    rpm -Uvh --force MIOpen-HIP-*.rpm && cd ~ && rm -rf ~/MLOpen/build
RUN mkdir -p /root/.config && mkdir -p /root/.config/miopen
COPY gfx906_64.cd.updb.txt /root/.config/miopen/
COPY gfx900_64.cd.updb.txt /root/.config/miopen/

RUN rm /opt/rocm/bin/target.lst

