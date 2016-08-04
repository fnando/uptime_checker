require "albatross-admin-client"
module UptimeChecker
  module Notifier
    class Kanbantool

      def self.enabled?
        Config.kanbantool_api_token
      end

      def self.id
        "kanbantool"
      end

      def self.notify(subject, message, options)
        duration = (Time.current - options[:ptime])
        board_id = options[:kanbantool]['board_id']
        if options[:state] == :up
          if duration >= 5.minutes
            Albatross::Admin::Client.endpoint = "http://sda.saude.gov.br/albatross-admin/"
            incident = Albatross::Admin::Client::Incident.new
            incident.status = "aberto"
            incident.reference_date = Time.now
            incident.due_date = Time.now + 1.day
            incident.description = "<div> #{subject}  - #{message} </br>Favor verificar a possível causa do incidente.</div>"
            incident.log = "<div> #{Time.now.strftime("%d/%m/%Y %H:%M")} - Uptime Checker - Abertura de Incidente</div>"
            application = Albatross::Admin::Client::Application.select(:id).where(slug: options[:name]).first
            incident.relationships[:application] = application
            incident.relationships[:'incident-category'] = Albatross::Admin::Client::IncidentCategory.new(id: 6)
            incident.relationships[:author] = Albatross::Admin::Client::User.new(id: 4)

            if incident.save
              params = {
                  api_token: Config.kanbantool_api_token,
                  name: subject,
                  description: "#{message} </br> #{incident.id}",
                  workflow_stage_id: options[:kanbantool]['workflow_stage_id'],
                  card_type_id: options[:kanbantool]['card_type_id'],
              #    assigned_user_id: options[:kanbantool]['assigned_user_id'],
                  swimlane_id: options[:kanbantool]['swimlane_id'],
                  custom_field_1: "Não"
              }
            else
              params = {
                  api_token: Config.kanbantool_api_token,
                  name: subject,
                  description: "#{message} </br> Não foi aberto incidente no albatross. Não foi possível encontrar a referência da aplicação",
                  workflow_stage_id: options[:kanbantool]['workflow_stage_id'],
                  card_type_id: options[:kanbantool]['card_type_id'],
              #    assigned_user_id: options[:kanbantool]['assigned_user_id'],
                  swimlane_id: options[:kanbantool]['swimlane_id'],
                  custom_field_1: "Não"
              }
            end
            HttpClient.post("https://xys.kanbantool.com/api/v1/boards/#{board_id}/tasks.xml", params)
          end

        #elsif options[:state] == :warning
        #  params = {
        #      api_token: Config.kanbantool_api_token,
        #      name: subject,
        #      description: message,
        #      workflow_stage_id: options[:kanbantool]['workflow_stage_id'],
        #      card_type_id: options[:kanbantool]['card_type_id'],
        #      #    assigned_user_id: options[:kanbantool]['assigned_user_id'],
        #      swimlane_id: options[:kanbantool]['swimlane_id'],
        #      custom_field_1: "Não"
        #  }
        #  HttpClient.post("https://xys.kanbantool.com/api/v1/boards/#{board_id}/tasks.xml", params)
        end

      end
    end
  end
end