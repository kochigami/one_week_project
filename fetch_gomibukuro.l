#!/usr/bin/env roseus

(load "package://pr2eus/pr2-interface.l")
(ros::roseus "pr2_send_joints")
(pr2-init)

(objects (list *pr2*))
;;(send *pr2* :locate #f(0 0 550))


(ros::roseus "pr2_send_joints")

(pr2)
(when (not (boundp '*irtviewer*))
  (make-irtviewer)
  (objects (list *pr2*))
  (send *irtviewer* :draw-objects))

(setq *ri* (instance pr2-interface :init))

(send *pr2* :reset-pose)
(if (boundp '*irtviewer*)
    (send *irtviewer* :draw-objects))
(send *ri* :angle-vector (send *pr2* :angle-vector) 3000)
;;(send *ri* :wait-interpolation)
 


;;棚に移動 ゴミ袋をつまむ
;;(send *pr2* :move-to (send *room* :spot "cook-spot" ) :world)
;;(send *pr2: locate #f(50 2700 0))



(send *pr2* :torso :waist-z :joint-angle 40)  ;;本当は300 
(send *pr2* :larm :collar-y :joint-angle 40)
(send *pr2* :larm :shoulder-p :joint-angle -20)
(send *pr2* :larm :elbow-p :joint-angle -90)
(send *pr2* :larm :wrist-p :joint-angle -10)
(send *pr2* :head :neck-p :joint-angle 15)

(send *pr2* :rarm :shoulder-p :joint-angle 0)
(send *pr2* :rarm :shoulder-r :joint-angle 0)


(send *ri* :angle-vector (send *pr2* :angle-vector ) 3000)
(send *ri* :start-grasp :arms :gain 0.01)

;;机に移動 お盆をとる
;;(send *pr2* :locate #f(-3800 -2500 0))



;;お盆にゴミ袋を置く
(send *pr2* :torso :waist-z :joint-angle 30)
(send *pr2* :larm :collar-y :joint-angle 30)
(send *pr2* :larm :shoulder-r :joint-angle 100)
(send *pr2* :larm :shoulder-p  :joint-angle  -10)
(send *pr2* :larm :wrist-p :joint-angle -10)
(send *pr2* :larm :wrist-r :joint-angle 60)
(send *pr2* :larm :elbow-p :joint-angle -40)
(send *pr2* :larm :elbow-r :joint-angle 10)
(send *ri* :angle-vector (send *pr2* :angle-vector ) 3000)

(send *ri* :stop-grasp :arms)

(send *pr2* :reset-pose)
(send *ri* :angle-vector (send *pr2* :angle-vector) 3000)

;;お盆をつかむ
(send *pr2* :torso :waist-z :joint-angle 20)

(send *pr2* :rarm :collar-y :joint-angle -40)
(send *pr2* :larm :collar-y :joint-angle 40)

(send *pr2* :rarm :shoulder-p :joint-angle 30)
(send *pr2* :larm :shoulder-p :joint-angle 30)

(send *pr2* :larm :shoulder-r :joint-angle 60)
(send *pr2* :rarm :shoulder-r :joint-angle -60)

(send *pr2* :rarm :elbow-p :joint-angle -100)
(send *pr2* :larm :elbow-p :joint-angle -100)

(send *pr2* :larm :elbow-r :joint-angle 100)
(send *pr2* :rarm :elbow-r :joint-angle -100)

(send *pr2* :arms :wrist-p :joint-angle -10)

(send *ri* :angle-vector (send *pr2* :angle-vector) 3000)

(send *ri* :start-grasp :arms :gain 0.01)


;;お盆を持って移動する
;;(send *ri* :move-pos-unsafe     )

;;人に渡す お盆が傾きゴミ袋が滑り落ちる

(send *pr2* :larm :wrist-r :joint-angle -40)
(send *pr2* :rarm :wrist-r :joint-angle 40)
(send *ri* :angle-vector (send *pr2* :angle-vector))
(speak-jp "ゴミぶくろをいれてくれ")
(speak-jp "あとはまかせた")

;;人がゴミ袋を入れてくれる pr2に何か合図をする


(ros::load-ros-manifest "roseus")
(ros::roseus "listener")

(setq *ri* (instance pr2-interface :init))

(defclass string-cb-class
  :super propertied-object
  :slots ())

(defmethod string-cb-class
  (:init () (ros::subscribe "joint_states" sensor_msgs::JointState #'send self :string-cb))
  (:string-cb (msg) 
	      (progn (print (setq effort (elt (send msg :effort ) 14)))
		     (if (> effort 1.0 ) 
(progn
(send *ri* :stop-grasp :larm)
(send *pr2* :larm :collar-y :joint-angle 50)
(send *ri* :angle-vector (send *pr2* :angle-vector ) 3000)
)))))

(setq m (instance string-cb-class :init))
(do-until-key
(ros::spin-once)) 
