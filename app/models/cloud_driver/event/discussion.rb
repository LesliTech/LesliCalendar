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
@description Model for project discussions. A discussion is a comment or a response to a comment.
    This class inherits all its functionality from the *CloudObject::Discussion* class
=end
    class Event::Discussion < CloudObject::Discussion
        belongs_to :cloud_object, class_name: "Event", foreign_key: "cloud_driver_events_id"
        belongs_to :parent, class_name: "Discussion", optional: true
        belongs_to :user, class_name: "::User", foreign_key: "users_id"
        has_many :children, class_name: "Discussion", foreign_key: "parent_id"
    end
end
