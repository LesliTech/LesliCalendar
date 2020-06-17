module CloudDriver
=begin

Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   Carlos Hermosilla
@license  Propietary - all rights reserved.
@version  0.1.0-alpha
@description Model for workflow actions. Each action represents something that must be done when
    a cloud_object changes status
=end
    class Workflow::Action < CloudObject::Workflow::Action
        belongs_to :workflow, class_name: "Workflow", foreign_key: "cloud_driver_workflows_id"
        belongs_to :workflow_including_deleted, class_name: "Workflow", foreign_key: "cloud_driver_workflows_id", with_deleted: true
        belongs_to :initial_status, class_name: "Workflow::Status", foreign_key: "initial_status_id", optional: true
        belongs_to :final_status, class_name: "Workflow::Status", foreign_key: "final_status_id"

    end
end
