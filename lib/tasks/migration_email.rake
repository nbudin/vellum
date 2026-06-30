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
      hosting.

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

    already_sent, pending = people_projects.partition { |person, _| person.migration_emailed_at.present? }

    if already_sent.any?
      puts "Skipping #{already_sent.size} already-notified recipient(s)."
    end
    puts "#{pending.size} recipient(s) to notify.\n\n"

    pending.each do |person, projects|
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
        person.update_column(:migration_emailed_at, Time.now)
        puts "Sent to #{person.email}"
        sleep 2
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

  desc <<~DESC
    Preview or send followup emails to members of projects that have been exported
    to Google Drive but not yet notified. Marks projects as notified after sending.

    Usage:
      bundle exec rake vellum:notify_exported          # preview
      SEND=true bundle exec rake vellum:notify_exported  # send
  DESC
  task notify_exported: :environment do
    # ── Edit this template before sending ─────────────────────────────────
    #
    # Available variables:
    #   %{name}         — the person's first name (or full name if no first name)
    #   %{project_list} — bulleted list of exported projects with Drive folder links
    #
    subject = "Your Vellum projects have been migrated to Google Drive"

    body_template = <<~BODY
      Hi %{name},

      Your Vellum projects have been migrated to Google Drive and shared with you.
      You should now have access to the following folders:

      %{project_list}
      Please let me know if you have any trouble accessing your projects, or if
      anything looks wrong or missing.  Thanks so much!

      Nat Budin
      natbudin@gmail.com
    BODY
    # ──────────────────────────────────────────────────────────────────────

    from    = "natbudin@gmail.com"
    send_it = ENV['SEND'] == 'true'

    exported_projects = Project.where.not(google_drive_folder_url: nil)
                               .where(google_drive_notified_at: nil)
                               .includes(:members)
                               .order(:name)

    if exported_projects.empty?
      puts "No exported-but-unnotified projects found."
      next
    end

    # Build a map of person -> [projects]
    people_projects = Hash.new { |h, k| h[k] = [] }
    exported_projects.each do |project|
      project.members.each do |person|
        next if person.email.blank?
        people_projects[person] << project
      end
    end

    puts "#{people_projects.size} recipients across #{exported_projects.size} project(s).\n\n"

    people_projects.each do |person, projects|
      name = person.firstname.presence || person.name.presence || person.email

      project_list = projects.map { |p| "  * #{p.name}: #{p.google_drive_folder_url}" }.join("\n")
      body = body_template % { name: name, project_list: project_list }

      if send_it
        ActionMailer::Base.mail(
          from:    from,
          to:      person.email,
          subject: subject,
          body:    body
        ).deliver_now
        puts "Sent to #{person.email}"
        sleep 2
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

    if send_it
      exported_projects.update_all(google_drive_notified_at: Time.now)
      puts "\nMarked #{exported_projects.size} project(s) as notified."
    else
      puts "\nDone. (Run with SEND=true to deliver and mark projects as notified.)"
    end
  end
end
