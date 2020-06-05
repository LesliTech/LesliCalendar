module CloudDriver
    #class Event::File < ApplicationRecord
    class Event::File < CloudObject::File
        belongs_to :cloud_object, class_name: "CloudDriver::Event", foreign_key: "cloud_driver_events_id"
        #mount_uploader :attachment, FileUploader

        enum file_type: {
            agreement: "agreement",
            termination: "termination",
            prolongation: "prolongation",
            appendant: "appendant",
            visit_old_report: "visit_old_report", #old_report
            marketing: "marketing",
            correspondance: "correspondance",
            datenbanken_migration: "datenbanken_migration",
            kop_doc: "kop_doc",
            approval: "approval",
            customer_data: "customer_data",
            generated_document: "generated_document",
            immo_private_maintenance_servicing: "immo_private_maintenance_servicing",
            immo_private_plans_floor_plans: "immo_private_plans_floor_plans",
            immo_private_supply_and_service_contracts: "immo_private_supply_and_service_contracts",
            immo_public_cadastre: "immo_public_cadastre",
            immo_public_land_register_extract: "immo_public_land_register_extract",
            immo_public_property_tax_and_unit_value: "immo_public_property_tax_and_unit_value",
            mark_navigator_report: "mark_navigator_report", #marktnavigator_bericht
            motivation: "motivation",
            notary_approval_declaration: "notary_approval_declaration",
            notary_document: "notary_document",
            notary_sign_off_from_board: "notary_sign_off_from_board",
            notary_version: "notary_version",
            other: "other",
            property_owner_billing: "property_owner_billing",
            property_owner_correspondence: "property_owner_correspondence",
            property_owner_insurance: "property_owner_insurance",
            property_owner_payments: "property_owner_payments",
            property_owner_property_pictures: "property_owner_property_pictures",
            property_owner_way: "property_owner_way",
            purchase_contract: "purchase_contract",
            real_estate_appraisal: "real_estate_appraisal", #immobiliengutachte
            template: "template",
            xls_sheet_upload: "xls_sheet_upload", #xls_sheet_hochladen
            annuity_calculations: "annuity_calculations",
            variant: "variant"
        }

        def self.allowed_file_extensions
            ["jpg","jpeg","png","pdf","doc","docx","tif","xls","xlsx","csv","html","eml","msg","emlx","oft","ost"]
        end
    end
end
