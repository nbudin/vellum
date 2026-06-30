namespace :vellum do
  desc <<~DESC
    Preview or send migration notification emails to all Vellum project members.

    Each person receives one email listing all their projects. By default this
    prints a preview to stdout. Set SEND=true to actually deliver the emails.

    Usage:
      bundle exec rake vellum:notify_migration          # preview
      SEND=true bundle exec rake vellum:notify_migration  # send
  DESC
  task notify_migration: :environment do
    # ── Edit this template before sending ─────────────────────────────────
    #
    # Available variables:
    #   %{name}         — the person's first name (or full name if no first name)
    #   %{project_list} — bulleted list of their Vellum projects
    #
    subject = "Vellum is being retired and your project will be migrated to Google Docs"

    body_template = <<~BODY
      Hi %{name}, thanks so much for using Vellum!

      I'm writing to let you know that after over a decade of maintenance, I'm making plans to take Vellum offline.
      It's become impossible to keep Vellum up to date with security updates and continue maintaining its database
      hosting.  I realize this might be disappointing, and I'm sorry it has come to this step.

      In order to keep your writing available to you, I'm migrating everything on Vellum to Google Docs.  Each project
      will have its own Google Drive folder, which will be shared with you and your co-authors.  I'll also be making
      backups of all your work, so no data will be lost, and I'm planning to retain those backups indefinitely.  If you
      find anything is missing in the Google Drive export of your projects, I can restore it from the database backups.

      Your projects on Vellum are:
      %{project_list}

      I'm planning to begin the migration to Google Docs on Monday, July 20.  If you have any questions or concerns
      before this, please feel free to reach out and let me know.  Thanks so much!

      Nat Budin
      natbudin@gmail.com
    BODY
    # ──────────────────────────────────────────────────────────────────────

    from    = "natbudin@gmail.com"
    send_it = ENV['SEND'] == 'true'

    # Build a map of person -> [projects], excluding people with no email
    people_projects = Hash.new { |h, k| h[k] = [] }
    Project.includes(:members).order(:name).each do |project|
      project.members.each do |person|
        next if person.email.blank?
        people_projects[person] << project
      end
    end

    puts "#{people_projects.size} recipients found.\n\n"

    people_projects.each do |person, projects|
      name         = person.firstname.presence || person.name.presence || person.email
      project_list = projects.map { |p| "  * #{p.name}: https://vellum.aegames.org/projects/#{p.id}" }.join("\n")
      body         = body_template % { name: name, project_list: project_list }

      if send_it
        ActionMailer::Base.mail(
          from:    from,
          to:      person.email,
          subject: subject,
          body:    body
        ).deliver_now
        puts "Sent to #{person.email}"
      else
        puts "=" * 60
        puts "To:      #{person.email}"
        puts "From:    #{from}"
        puts "Subject: #{subject}"
        puts "-" * 60
        puts body
        puts
      end
    end

    puts "\nDone. (Run with SEND=true to deliver.)" unless send_it
  end
end
