require_dependency "cloud_driver/application_controller"

module CloudDriver
    class Event::FilesController < CloudObject::FilesController

        def privileges
            {
                new: ["options"],
                index: [],
                show: ["options"],
                destroy: []
            }
        end

    end
end

