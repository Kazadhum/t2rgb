# 1. Base Image
FROM osrf/ros:noetic-desktop-full

ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}

ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt-get update && apt-get install -y apt-utils build-essential psmisc vim-gtk
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && apt-get install -q -y python3-catkin-tools
RUN apt-get update && apt-get install -q -y ros-noetic-hector-gazebo-plugins


# 2. Setup Catkin Workspace
RUN cd /home \
    && mkdir catkin_ws \
    && cd catkin_ws \
    && mkdir src

RUN . /opt/ros/noetic/setup.sh \
    && cd /home/catkin_ws \
    && catkin_make

# Copy packages
RUN . /opt/ros/noetic/setup.sh \
    && cd /home/catkin_ws/src \
    && mkdir t2rgb \
    && cd t2rgb \
    && catkin_create_pkg t2rgb_description std_msg rospy roscpp \
    && catkin_create_pkg t2rgb_bringup std_msg rospy roscpp

RUN cd /home/catkin_ws/src/t2rgb/t2rgb_description \
    && rm -r *
COPY t2rgb_description /home/catkin_ws/src/t2rgb/t2rgb_description

RUN cd /home/catkin_ws/src/t2rgb/t2rgb_bringup \
    && rm -r *
COPY t2rgb_bringup /home/catkin_ws/src/t2rgb/t2rgb_bringup

RUN . /opt/ros/noetic/setup.sh \
    && cd /home/catkin_ws \
    && catkin_make