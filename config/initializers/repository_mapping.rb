require_dependency 'repositories/in_memory'

Raidit::Application.configure do

  config.to_prepare do
    if ENV["REAL_DB"]
      Repository.configure(
        "User"        => ActiveRecordRepo::UserRepo.new,
        "Guild"       => ActiveRecordRepo::GuildRepo.new,
        "Character"   => ActiveRecordRepo::CharacterRepo.new,
        "Raid"        => ActiveRecordRepo::RaidRepo.new,
        "Signup"      => ActiveRecordRepo::SignupRepo.new,
        "Permission"  => ActiveRecordRepo::PermissionRepo.new,
        "Comment"     => ActiveRecordRepo::CommentRepo.new
      )
    else
      Repository.configure(
        "User"        => InMemory::UserRepo.new,
        "Guild"       => InMemory::GuildRepo.new,
        "Character"   => InMemory::CharacterRepo.new,
        "Raid"        => InMemory::RaidRepo.new,
        "Signup"      => InMemory::SignupRepo.new,
        "Permission"  => InMemory::PermissionRepo.new,
        "Comment"     => InMemory::CommentRepo.new
      )

      # Set up our seed data for the development setup
      if Rails.env.development?
        Repository.for(Guild).save(
          exiled = Guild.new(:name => "Exiled", :region => "US", :server => "Detheroc")
        )

        Repository.for(Guild).save(
          mind_crush = Guild.new(:name => "Mind Crush", :region => "US", :server => "Kil'Jaeden")
        )

        Repository.for(User).save(
          jason = User.new(:login => "jason", :password => "password")
        )

        Repository.for(User).save(
          raider = User.new(:login => "raider", :password => "password")
        )

        Repository.for(Character).save(
          weemuu = Character.new(:name => "Weemuu", :user => jason, is_main: true,
                                :character_class => "mage", :guild =>  exiled)
        )

        Repository.for(Character).save(
          wonko = Character.new(:name => "Wonko", is_main: true,
            :user => jason, :character_class => "warrior", :guild => mind_crush)
        )

        Repository.for(Character).save(
          weemoo = Character.new(:name => "Weemoo",
            :user => jason, :character_class => "shaman", :guild => mind_crush)
        )

        Repository.for(Character).save(
          weemoo = Character.new(:name => "Pandy",
            :user => jason, :character_class => "druid")
        )

        Repository.for(Character).save(
          phouchg = Character.new(:name => "Phouchg", is_main: true,
            :user => raider, :character_class => "hunter", :guild => exiled)
        )

        Repository.for(Permission).save(
          Permission.new(:user => jason, :guild => exiled,
                        :permissions => Permission::ALL_PERMISSIONS)
        )

        (1.week.ago.to_date..2.weeks.from_now.to_date).each do |day|
          raid = Raid.new :when => day, :owner => exiled, :where => "ICC",
            :start_at => Time.parse("20:00"), :invite_at => Time.parse("19:30")

          raid.set_role_limit :tank, (rand * 5).to_i
          raid.set_role_limit :dps, (rand * 20).to_i
          raid.set_role_limit :healer, (rand * 5).to_i

          Repository.for(Raid).save(raid)

          SignUpToRaid.new(jason).run raid, weemuu, "dps"
          SignUpToRaid.new(raider).run raid, phouchg, "healer"
        end
      end
    end
  end

end
