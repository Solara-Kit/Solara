class DoctorHandler < BaseHandler
    def mount
        @server.mount_proc('/brand/doctor') do |req, res|
            if req.request_method == 'GET'
                begin
                    query = CGI.parse(req.query_string)
                    brand_key = query['brand_key']&.first

                    if brand_key
                        doctor_result = run_doctor(brand_key)
                        res.status = 200
                        res.body = JSON.generate({ success: true, result: doctor_result })
                    else
                        res.status = 400
                        res.body = JSON.generate({ success: false, error: 'Missing brand_key parameter' })
                    end
                rescue StandardError => e
                    handle_error(res, e, "Error running doctor")
                end
            else
                method_not_allowed(res)
            end
            res.content_type = 'application/json'
        end
    end

    def run_doctor(brand_key)
        errors = SolaraManager.new.doctor(brand_key)
        {
            message: "Health check completed.",
            brand_key: brand_key,
            passed: errors.empty?,
            errors: errors
        }
    rescue StandardError => e
        Solara.logger.failure("Error running doctor: #{e.message}")
        raise
    end
end