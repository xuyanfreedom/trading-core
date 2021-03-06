;;;; agent-communication-pair-trading.lisp
;;; A simple example of cooperative communication between agents.

(in-package #:trading-core)

(setf logv:*log-output* nil)

;; Set the location of the historical data used in the simulation if different from the default.
(setf *historical-data-path* "C:/Worden/TeleChart/Export/SP500_Components/")

;; Set the location where the analysis result template is located if different from default
;(setf *ui-template-path* #P"C:/Users/Jonathan/Lisp/projects/trading-core/trading-ui/templates/")

;; Set the location where the analysis results will be placed if different from default
;(setf *analysis-results-path* #P"C:/Users/Jonathan/Lisp/projects/trading-core/trading-ui/")

;; load historical data
(defparameter *security-data*
  `((:nue . ,(load-event-data "NUE"
                              :start-date "2005-01-01" :end-date "2012-01-01"))
    (:x . ,(load-event-data "X"
                            :start-date "2005-01-01" :end-date "2012-01-01"))))

;; create the trading agents that will process the historical data
(let ((a1 (make-instance 'simple-model-comm
                           :L 89 :security :x))
      (a2 (make-instance 'simple-model-comm
                           :L 89 :security :nue)))
  (setf (recipients-list a1) (list a2)
        (recipients-list a2) (list a1)
        *agents* (list a1 a2)))

;; create a list of all events in datetime order for the simulation engine
(defparameter *events* (sort (copy-list (union (cdr (assoc :nue *security-data*))
                                               (cdr (assoc :x *security-data*))))
                             (lambda (x y)
                               (local-time:timestamp< (timestamp x) (timestamp y)))))

(run-simulation *events*)

(analyze *agents* *security-data*)

;; EOF
