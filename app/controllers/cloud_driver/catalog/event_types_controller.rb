require_dependency "cloud_driver/application_controller"

module CloudDriver
=begin
Copyright (c) 2020, all rights reserved.

All the information provided by this platform is protected by international laws related  to
industrial property, intellectual property, copyright and relative international laws.
All intellectual or industrial property rights of the code, texts, trade mark, design,
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// ·

=end
    class Catalog::EventTypesController < ApplicationController
        before_action :set_event_type, only: [:update, :destroy]

        def privileges
            {
                index: [],
                new: ["options"],
                show: [],
                destroy: [],
            }
        end

=begin
@return [HTML|JSON] HTML view for listing all event priorities or a Json that contains a list
    of all event priorities associated to this *account*
@description Retrieves and returns all event priorities associated to a *CloudDriver::Account*.
    The account is obtained directly from *current_user*. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    this.http.get(`127.0.0.1/driver/catalog/event_types`);
=end
        def index
            respond_to do |format|
                format.html {}
                format.json do
                    respond_with_successful(Catalog::EventType.index(current_user, @query))
                end
            end
        end

=begin
@return [HTML|Json] HTML view showing the requested event type or a Json that contains the
    information of the event type. If there is an error, an explanation message is sent
@description Retrieves and returns the requested event type. The id of the
    type is within the *params* attribute of the controller. The HTTP request has to specify
    wheter the HTML or the JSON text should be rendered
@example
    # Executing this controller's action from javascript's frontend
    let event_type_id = 1;
    this.http.get(`127.0.0.1/driver/catalog/event_types/${event_type_id}`);
=end
        def show
            respond_to do |format|
                format.html {}
                format.json do
                    set_event_type
                    return respond_with_not_found unless @event_type

                    respond_with_successful(@event_type.show)
                end
            end
        end

=begin
@return [HTML] HTML view for creating a new event type
@description returns an HTML view with a form so users can create a new event type
@example
    # Executing this controller's action from javascript's frontend
    this.url.go('/driver/catalog/event_types/new')
=end
        def new
        end

=begin
@return [HTML] HTML view for editing the event type
@description returns an HTML view with a form so users edit an existing event type
@example
    # Executing this controller's action from javascript's frontend
    let event_type_id = 3;
    this.url.go(`/driver/catalog/event_types/${event_type_id}/edit`)
=end
        def edit
        end

=begin
@controller_action_param :name [String] The name of the new type
@controller_action_param :model_type [Integer] The model_type of the new type
    The higher the number means it is more important.
@return [Json] Json that contains wheter the creation of the event type was successful or not.
    If it is not successful, it returns an error message
@description Creates a new event type associated to the *current_user*'s *account*
@example
    # Executing this controller's action from javascript's frontend
    let data = {
        event_type: {
            name: "Important",
            model_type: 100
        }
    };
    this.http.post('127.0.0.1/driver/catalog/event_types', data);
=end
        def create
            event_type = Catalog::EventType.new(event_type_params)
            event_type.cloud_driver_accounts_id = current_user.account.id

            if event_type.save
                respond_with_successful(event_type)
            else
                respond_with_error(event_type.errors.full_messages.to_sentence)
            end
        end

=begin
@controller_action_param :name [String] The name of the type
@controller_action_param :model_type [Integer] The model_type of the new type
@return [Json] Json that contains wheter the event type was successfully updated or not.
    If it it not successful, it returns an error message
@description Updates an existing event type associated to the *current_user*'s *account*.
@example
    # Executing this controller's action from javascript's frontend
    let event_type_id = 4;
    let data = {
        event_type: {
            name: "Very Important",
            model_type: 101
        }
    };
    this.http.put(`127.0.0.1/driver/catalog/event_types/${event_type_id}`, data);
=end
        def update
            return respond_with_not_found unless @event_type

            if @event_type.update(event_type_params)
                respond_with_successful(@event_type)
            else
                respond_with_error(@event_type.errors.full_messages.to_sentence)
            end
        end

=begin
@return [Json] Json that contains wheter the event type was successfully deleted or not.
    If it it not successful, it returns an error message
@description Deletes an existing *event* *type* associated to the *current_user*'s *account*.
    If there is an existing *event* associated to the *event* *type*, it cannot be deleted
@example
    # Executing this controller's action from javascript's frontend
    let event_type_id = 4;
    this.http.delete(`127.0.0.1/driver/catalog/event_types/${event_type_id}`);
=end
        def destroy
            return respond_with_not_found unless @event_type

            if @event_type.destroy
                respond_with_successful
            else
                respond_with_error(@event_type.errors.full_messages.to_sentence)
            end
        end

        def options
            respond_with_successful
        end

        private

=begin
@return [void]
@description Sets the variable @event_type. The variable contains the *event* *type*
    to be handled by the controller action that called this method
@example
    #suppose params[:id] = 1
    puts @event_type # will display nil
    set_event_type
    puts @event_type # will display an instance of CloudDriver:Catalog::EventType
=end
        def set_event_type
            @event_type = Catalog::EventType.find_by(
                id: params[:id],
                cloud_driver_accounts_id: current_user.account.driver.id
            )
        end

=begin
@return [Parameters] Allowed parameters for the event type
@description Sanitizes the parameters received from an HTTP call to only allow the specified ones.
    Allowed params are _:name_, _:model_type_
@example
    # supose params contains {
    #    "event_type": {
    #        "id": 5,
    #        "name": "Low",
    #        "model_type": "CloudHouse::Project"
    #    }
    #}
    filtered_params = event_type_params
    puts filtered_params
    # will remove the id and only print {
    #    "event_type": {
    #        "name": "Low",
    #        "model_type": "CloudHouse::Project"
    #    }
    #}
=end
        def event_type_params
            params.require(:event_type).permit(:name, :model_type)
        end
    end
end
