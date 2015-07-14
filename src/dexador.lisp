(in-package :cl-user)
(defpackage dexador
  (:nicknames :dex)
  (:use :cl)
  (:shadow :get
           :delete)
  (:import-from :dexador.backend.usocket
                :request
                :retry-request
                :ignore-and-continue)
  (:import-from :dexador.connection-cache
                :*connection-pool*
                :*use-connection-pool*
                :make-connection-pool)
  (:import-from :dexador.error
                :http-request-failed
                :http-request-not-found
                :response-body
                :response-status
                :response-headers
                :request-uri)
  (:import-from :dexador.util
                :*default-timeout*)
  (:export :request
           :get
           :post
           :head
           :put
           :delete
           :*default-timeout*
           :*connection-pool*
           :*use-connection-pool*
           :make-connection-pool

           ;; Errors
           :http-request-failed
           :http-request-not-found
           :response-body
           :response-status
           :response-headers
           :request-uri

           ;; Restarts
           :retry-request
           :ignore-and-continue))
(in-package :dexador)

(defun get (uri &rest args
            &key version headers basic-auth cookie-jar keep-alive use-connection-pool timeout max-redirects force-binary
              ssl-key-file ssl-cert-file ssl-key-password stream verbose)
  (declare (ignore version headers basic-auth cookie-jar keep-alive use-connection-pool timeout max-redirects force-binary ssl-key-file ssl-cert-file ssl-key-password stream verbose))
  (apply #'request uri :method :get args))

(defun post (uri &rest args
             &key version content headers basic-auth cookie-jar keep-alive use-connection-pool timeout force-binary
               ssl-key-file ssl-cert-file ssl-key-password stream verbose)
  (declare (ignore version content headers basic-auth cookie-jar keep-alive use-connection-pool timeout force-binary ssl-key-file ssl-cert-file ssl-key-password stream verbose))
  (apply #'request uri :method :post args))

(defun head (uri &rest args
             &key version headers basic-auth cookie-jar timeout max-redirects force-binary
               ssl-key-file ssl-cert-file ssl-key-password stream verbose)
  (declare (ignore version headers basic-auth cookie-jar timeout max-redirects force-binary ssl-key-file ssl-cert-file ssl-key-password stream verbose))
  (apply #'request uri :method :head :use-connection-pool nil args))

(defun put (uri &rest args
            &key version content headers basic-auth cookie-jar keep-alive use-connection-pool timeout force-binary
              ssl-key-file ssl-cert-file ssl-key-password stream verbose)
  (declare (ignore version content headers basic-auth cookie-jar keep-alive use-connection-pool timeout force-binary ssl-key-file ssl-cert-file ssl-key-password stream verbose))
  (apply #'request uri :method :put args))

(defun delete (uri &rest args
               &key version headers basic-auth cookie-jar keep-alive use-connection-pool timeout force-binary
                 ssl-key-file ssl-cert-file ssl-key-password stream verbose)
  (declare (ignore version headers basic-auth cookie-jar keep-alive use-connection-pool timeout force-binary ssl-key-file ssl-cert-file ssl-key-password stream verbose))
  (apply #'request uri :method :delete args))

(defun ignore-and-continue (e)
  (let ((restart (find-restart 'ignore-and-continue e)))
    (when restart
      (invoke-restart restart))))

(defun retry-request (times)
  (etypecase times
    (condition
     (let ((restart (find-restart 'retry-request times)))
       (when restart
         (invoke-restart restart))))
    (integer
     (retry-request-ntimes times))))

(defun retry-request-ntimes (n)
  (declare (type integer n))
  (lambda (e)
    (declare (type condition e))
    (let ((restart (find-restart 'retry-request e)))
      (when restart
        (when (< 0 n)
          (decf n)
          (invoke-restart restart))))))
