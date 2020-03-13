require_dependency "cloud_driver/application_controller"

module CloudDriver
    class Event::FilesController < CloudObject::FilesController
    end
end
=begin
    class Event::FilesController < ApplicationController
        def create
            begin
                file = Event::File.new (event_file_params)
                file.event = Event.find(1)
                #file.file.attach(event_file_params[:file])
                file.save
            rescue => exception
                p "~   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~"
                p exception
                p "~   ~   ~   ~   ~   ~   ~   ~   ~   ~   ~"    
            end
            
            
            
        end

        private

        def event_file_params
            params.fetch(:event_file).permit(:name, :file)
        end
    end
=end

