alias TangoTango.Core.Messaging

alias TangoTango.Persistence.Repo
alias TangoTango.Persistence.CassandraRepo
alias TangoTango.Persistence.Users
alias TangoTango.Persistence.Users.User
alias TangoTango.Persistence.Users.Unsecured, as: UnsecuredUsers
alias TangoTango.Persistence.Users.Devices
alias TangoTango.Persistence.Users.Devices.Unsecured, as: UnsecuredDevices
alias TangoTango.Persistence.Users.Device
alias TangoTango.Persistence.Organizations
alias TangoTango.Persistence.Organizations.Organization
alias TangoTango.Persistence.Organizations.OrganizationAdmin
alias TangoTango.Persistence.Organizations.InteropAgreement
alias TangoTango.Persistence.Organizations.InteropAgreements
alias TangoTango.Persistence.RedisUtils

alias TangoTango.Persistence.Organizations.InteropAgreements.Unsecured,
  as: UnsecuredInteropAgreements

alias TangoTango.Persistence.Organizations.Unsecured, as: UnsecuredOrgs
alias TangoTango.Persistence.OrganizationFeatures
alias TangoTango.Persistence.OrganizationFeatures.Unsecured, as: UnsecuredOrgFeatures
alias TangoTango.Persistence.AuditLog
alias TangoTango.Persistence.AuditlogManager
alias TangoTango.Persistence.CallDetailRecords
alias TangoTango.Persistence.Channels
alias TangoTango.Persistence.Channels.Channel
alias TangoTango.Persistence.Channels.Unsecured, as: UnsecuredChannels
alias TangoTango.Persistence.LatestLocationByOrg
alias TangoTango.Persistence.MessageAttachments
alias TangoTango.Persistence.Messages
alias TangoTango.Persistence.Messages.Message
alias TangoTango.Persistence.Messages.Attachment
alias TangoTango.Persistence.RegistrationList
alias TangoTango.Persistence.RegistrationList.UnregisteredSite
alias TangoTango.Persistence.SeedHelpers
alias TangoTango.Persistence.Sites
alias TangoTango.Persistence.Sites.Site
alias TangoTango.Persistence.Sites.Unsecured, as: UnsecuredSites
alias TangoTango.Persistence.ToneEvents
alias TangoTango.Persistence.Tones
alias TangoTango.Persistence.Tones.Tone
alias TangoTango.Persistence.Tones.Unsecured, as: UnsecuredTones
alias TangoTango.Persistence.Types.Avatar
alias TangoTango.Persistence.Types.MacAddress
alias TangoTango.Persistence.Types.PhoneNumber
alias TangoTango.Persistence.ExternalEvents
alias TangoTango.Persistence.ExternalEvents.ExternalEvent
alias TangoTango.Persistence.ExternalEvents.ExternalEventConfig
alias TangoTango.Persistence.ExternalEvents.ExternalEventConfigs

alias TangoTango.Persistence.ExternalEvents.ExternalEventConfigs.Unsecured,
  as: UnsecuredEventConfigs

defmodule N do
  def seed() do
    tango_org = SeedHelpers.tango_tango_org()
    SeedHelpers.attempt_insert(%Organization{org_name: "Nathan's Org"})
    nathans_org = UnsecuredOrgs.get_organization_by_name("Nathan's Org")
    SeedHelpers.device_limit(tango_org, 1000)
    SeedHelpers.device_limit(nathans_org, 1000)

    SeedHelpers.attempt_insert(
      User.changeset(%User{}, %{
        first_name: "Nathan",
        last_name: "Alderson",
        org_id: tango_org.id,
        email: "nathan@tangotango.net",
        identity: "sms|61c0a828d6496fcf66e5d812",
        phone_number: "19314462935",
        designator: "NAT"
      })
    )

    for i <- 1..15 do
      i = i |> Integer.to_string() |> String.pad_leading(2, "0")

      SeedHelpers.attempt_insert(
        User.changeset(%User{}, %{
          first_name: "User",
          last_name: "Person #{i}",
          org_id: tango_org.id,
          email: "user.person#{i}@tangotango.net",
          identity: "auth0|0000000000000000000000#{i}",
          phone_number: "125655500#{i}"
        })
      )
    end

    # for i <- 1..5 do
    #   i = i |> Integer.to_string() |> String.pad_leading(2, "0")
    #   SeedHelpers.attempt_insert(%Channel{name: "tango channel #{i}", org_id: tango_org.id})
    # end
    # for i <- 1..5 do
    #   i = i |> Integer.to_string() |> String.pad_leading(2, "0")
    #   SeedHelpers.attempt_insert(%Channel{name: "nathan's channel #{i}", org_id: nathans_org.id})
    # end
    SeedHelpers.set_org_admin(tango_org, N.me())

    SeedHelpers.attempt_insert(
      User.changeset(%User{}, %{
        first_name: "Darth",
        last_name: "Maulderson",
        org_id: nathans_org.id,
        email: "darth_maulderson@sith.gov",
        identity: "sms|6287d55f1e2b004f283490c8",
        phone_number: "12565421532",
        designator: "DAR"
      })
    )

    result =
      SeedHelpers.attempt_insert(%Device{
        device_id: "aae8093a6dd1128e",
        name: "Google Pixel 4a",
        platform: :android,
        platform_version: "13",
        vendor: "Google",
        model: "Pixel 4a",
        app_version: "1.3.7+684",
        release_build: true,
        dnd: true,
        activation_status: :active,
        user_id: N.me().id
      })

    case result do
      :ok ->
        nil

      {:ok, device} ->
        UnsecuredDevices.update_device_token(%{
          device_id: device.id,
          token_value:
            "d_Dn-zqSQo6RuelR6CDRRh:APA91bERzaOfSKJyC3B-UuVJXDGBPXqkmlRdMj5_FuDs3wB32wFKuKnViVelofnzGrJPzTuqX1Lr8VYZNT3c0rFiS8Ab3s8BUZoLGV7zKWoumFMDUVmRCzLYP72vhe1npFqgKQf4aEEi",
          token_type: :fcm
        })
    end

    SeedHelpers.attempt_insert(%Site{
      name: "Site 01",
      org_id: tango_org.id,
      mac_address: "00:00:00:00:00:01"
    })
  end

  def first_device(user), do: Repo.preload(user, :devices).devices |> Enum.at(0)

  def set_log_level(level \\ :info), do: Logger.configure(level: level)
  def dont_truncate(), do: IEx.configure(inspect: [limit: :infinity, printable_limit: :infinity])

  def me(), do: UnsecuredUsers.get_user_by_email("nathan@tangotango.net")
  def tango(), do: UnsecuredOrgs.get_organization_by_name("Tango Tango")

  def create_unregistered_sites(count, type \\ :dev) do
    for i <- 1..count do
      num = String.pad_leading("#{i}", 2, "0")

      %UnregisteredSite{}
      |> UnregisteredSite.changeset(%{
        name: "Unregistered Site #{num}",
        mac_address: "00:00:00:00:00:#{num}",
        type: type,
        status: :waiting
      })
      |> Repo.insert()
    end
  end

  def create_sites(count, opts \\ []) do
    type = Keyword.get(opts, :type, :dev)
    org_id = Keyword.get(opts, :org_id, tango().id)
    <<four_bytes::binary-size(4), _::binary>> = :crypto.hash(:sha, "#{org_id}")

    middle =
      four_bytes
      |> :binary.bin_to_list()
      |> Enum.map(&Integer.to_string(&1, 16))
      |> Enum.map(&String.pad_leading(&1, 2, "0"))
      |> Enum.join(":")

    for i <- 1..count do
      num = String.pad_leading("#{i}", 2, "0")

      UnsecuredSites.create_site(%{
        name: "Site #{num}",
        mac_address: "01:#{middle}:#{num}",
        org_id: org_id,
        type: type
      })
    end
  end

  def create_tone_events(count, tone, call_id \\ nil) do
    call_id = call_id || 1
    entities = [{tone.id, :tone}, {tone.channel_id, :channel}, {tone.org_id, :org}]

    1..count
    |> Enum.flat_map(fn i ->
      {events, []} =
        ToneEvents.store_tone_event(entities, :now, tone.id, tone.channel_id, call_id, i)

      events
    end)
  end

  def send_messages(
        count,
        channel_id,
        type \\ :standard,
        text \\ nil,
        call_id \\ nil,
        tone_ids \\ []
      ) do
    channel = UnsecuredChannels.get_channel!(channel_id)
    now = Timex.now()

    for i <- 1..count do
      Messaging.send_message(
        channel,
        Message.new!(
          channel_id,
          Timex.shift(now, seconds: -i),
          :user,
          6_890_685_743_094_562_816,
          type,
          text || "Message #{i}",
          [],
          %{
            "callId" => "#{call_id}",
            "detectedToneIds" => Enum.join(tone_ids, ",")
          }
        )
      )
    end
  end

  def send_location_update(user, timestamp \\ Timex.now()) do
    lat = rand_interval(34.769604619877164, 34.66079144385748)
    long = rand_interval(-86.79176805114027, -86.48162697390367)

    record = %LatestLocationByOrg.LocationRecord{
      viewer_org_id: user.org_id,
      org_id: user.org_id,
      user_id: user.id,
      device_id: N.first_device(user).id,
      coords_latitude: lat,
      coords_longitude: long,
      coords_accuracy: 3.0,
      coords_speed: 0,
      coords_heading: nil,
      coords_altitude: nil,
      battery_level: 1.0,
      battery_is_charging: false,
      event: "update",
      correlation_id: "#{timestamp}",
      timestamp: timestamp
    }

    LatestLocationByOrg.update_location(record)
  end

  def rand_interval(a, b), do: a + (b - a) * :rand.uniform()

  def create_users(count, org_id) do
    for i <- 1..count do
      num = String.pad_leading("#{i}", 4, "0")

      {:ok, user} =
        UnsecuredUsers.create_user(%{
          first_name: "User",
          last_name: "Person #{num}",
          org_id: org_id,
          email: "user.person#{num}@#{org_id}.org",
          identity: "fake|#{num}"
        })

      user
    end
  end

  def create_random_devices(count, org_id) do
    organization = UnsecuredOrgs.get_organization!(org_id) |> Repo.preload(:users)

    Enum.map(1..count, fn i ->
      platform = Enum.random([:ios, :android])
      push_status = Enum.random([:registered, :unregistered])
      activation_status = Enum.random([:active, :inactive, :pending])
      org_managed = Enum.random([true, false, false])

      user =
        if org_managed,
          do: Enum.random(organization.users ++ [nil]),
          else: Enum.random(organization.users)

      is_apple = platform == :ios
      i = Integer.to_string(i) |> String.pad_leading(4, "0")

      result =
        UnsecuredDevices.create_device(%{
          device_id: "device-#{i}",
          imei: "imei-#{i}",
          user_id: user && user.id,
          platform_version: if(is_apple, do: "15.4.1", else: "11"),
          platform: platform,
          model: if(is_apple, do: "iPhone", else: "Pixel 5"),
          vendor: if(is_apple, do: "Apple", else: "Google"),
          app_version: "1.2.3",
          activation_status: activation_status,
          managing_org_id: if(org_managed, do: org_id, else: nil)
        })

      case result do
        {:ok, device} ->
          if push_status == :registered do
            {:ok, _} =
              UnsecuredDevices.update_device_token(%{
                device_id: device.id,
                token_type: :fcm,
                token_value: "#{device.id}-fcm-token"
              })

            {:ok, _} =
              UnsecuredDevices.update_device_token(%{
                device_id: device.id,
                token_type: :ios_voip,
                token_value: "#{device.id}-voip-token"
              })
          end

        _ ->
          nil
      end
    end)
  end

  def create_alerts(count, config_id, type, opts \\ []) do
    config = UnsecuredEventConfigs.get(config_id)

    for i <- 1..count do
      num = String.pad_leading("#{i}", 4, "0")
      timestamp = Timex.shift(Timex.now(), seconds: -i)

      content =
        case type do
          "flock" ->
            %{
              title: Keyword.get(opts, :title, "Flock Event #{timestamp}"),
              call: Enum.random(["MEDICAL", "FIRE", "WEATHER", "RESCUE", "WRECK"]),
              source: "source1",
              reason: "reason1",
              vehicleModel: "Model",
              vehicleMake: "Make",
              vehicleColor: "Color",
              licensePlate: "PLATENUM",
              camera: "camera1",
              network: "network1",
              date: Timex.format!(timestamp, "%m/%d/%Y", :strftime),
              time: Timex.format!(timestamp, "%H:%M:%S", :strftime),
              image: "https://picsum.photos/500",
              extra_field: "extra_value"
            }

          "cad" ->
            %{
              title: Keyword.get(opts, :title, "CAD Event #{timestamp}"),
              address: "123 Main St",
              call: Enum.random(["MEDICAL", "FIRE", "WEATHER", "RESCUE", "WRECK"]),
              city: "Anytown",
              code: "69E08",
              cross: "Main St x 1st St",
              date: Timex.format!(timestamp, "%m/%d/%Y", :strftime),
              gps: "34.711188,-86.653937",
              w3w: "pursuing.smudges.walkway",
              id: "id-#{num}",
              info: Keyword.get(opts, :info, "Info #{num}"),
              place: "Place #{num}",
              priority: "bravo",
              time: Timex.format!(timestamp, "%H:%M:%S", :strftime),
              unit: "Unit #{num}"
            }
        end

      ExternalEvents.store_event(
        ExternalEvent.new!(
          config.org_id,
          timestamp,
          content.title,
          content,
          config_id,
          audio_arns:
            Keyword.get(opts, :audio_arns, [
              "arn:aws:s3:::event-email-staging-audio/1234test/this_is_opus.opus",
              "arn:aws:s3:::event-email-staging-audio/1234test/this_is_aac.aac"
            ]),
          announcement: Keyword.get(opts, :announcement, "Fake announcement"),
          type: type,
          raw_input: "raw input"
        )
      )
    end
  end

  def kill_pids(pidnums, reason \\ :kill) do
    pidnums
    |> Enum.map(&:erlang.list_to_pid(~c"<0.#{&1}.0>"))
    |> Enum.each(&Process.exit(&1, reason))
  end
end

N.set_log_level(:info)
N.seed()
