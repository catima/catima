if Rails.env.development?
  Annotate.set_defaults("exclude_tests" => "true", "sort" => "true")

  # Annotate models
  task annotate: :environment do
    puts "Annotating models..."
    system "bundle exec annotate"
  end

  # Run annotate task after db:migrate
  #  and db:rollback tasks
  Rake::Task["db:migrate"].enhance do
    Rake::Task["annotate"].invoke
  end

  Rake::Task["db:rollback"].enhance do
    Rake::Task["annotate"].invoke
  end
end
