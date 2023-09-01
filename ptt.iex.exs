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
    SeedHelpers.attempt_insert(%Device{
      device_id: "aae8093a6dd1128e",
      name: "Google Pixel 4a",
      platform: :android,
      platform_version: "13",
      vendor: "Google",
      model: "Pixel 4a",
      token: "euyxiQavQ9OGqzfZ57HeQ4:APA91bFNfP5lyWtIspT3H8nHKXpFzAK2RGF_l-safrCeoHfn8pvP0im5sTvMNwN0Kitk0hWlnn7Zm9yH6YHU_4isvuFfO0GXmZI-HPLjQZoH5VRm95_KADLE2AxLqFX4fcXn2Q8vvLDf",
      voip_token: nil,
      app_version: "1.3.7+684",
      release_build: true,
      dnd: true,
      activation_status: :active,
      user_id: N.me().id,
    })
    SeedHelpers.attempt_insert(%Site{
        name: "Site 01",
        org_id: tango_org.id,
        mac_address: "00:00:00:00:00:01",
    })
  end

  def first_device(user), do:
    Repo.preload(user, :devices).devices |> Enum.at(0)


  def set_log_level(level \\ :info), do: Logger.configure(level: level)
  def dont_truncate(), do: IEx.configure(inspect: [limit: :infinity, printable_limit: :infinity])

  def me(), do: UnsecuredUsers.get_user_by_email("nathan@tangotango.net")
  def tango(), do: UnsecuredOrgs.get_organization_by_name("Tango Tango")

  def create_sites(count, type \\ :cradlepoint) do
    for i <- 1..count do
      num = String.pad_leading("#{i}", 2, "0")
      UnsecuredSites.create_site(%{
        name: "Site #{num}",
        mac_address: "00:00:00:00:00:#{num}",
        org_id: tango().id,
        type: type
      })
    end
  end

  def create_tone_events(count, tone, call_id \\ nil) do
    call_id = call_id || 1
    entities = [{tone.id, :tone}, {tone.channel_id, :channel}, {tone.org_id, :org}]

    1..count |> Enum.flat_map(fn i ->
      {events, []} = ToneEvents.store_tone_event(entities, :now, tone.id, tone.channel_id, call_id, i)
      events
    end)
  end

  def send_messages(count, channel_id, type \\ :standard, text \\ nil, call_id \\ nil, tone_ids \\ []) do
    channel = UnsecuredChannels.get_channel!(channel_id)
    now = Timex.now()
    for i <- 1..count do
      Messaging.send_message(channel, Message.new!(
        channel_id, Timex.shift(now, seconds: -i), :user, 6890685743094562816, type, text || "Message #{i}", [], %{
          "callId" => "#{call_id}",
          "detectedToneIds" => Enum.join(tone_ids, ",")
        }
      ))
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
      {:ok, user} = UnsecuredUsers.create_user(%{
        first_name: "User",
        last_name: "Person #{num}",
        org_id: org_id,
        email: "user.person#{num}@organization.org",
        identity: "fake|#{num}",
        phone_number: "1256555#{num}"
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
      user = if org_managed, do: Enum.random(organization.users ++ [nil]), else: Enum.random(organization.users)
      is_apple = platform == :ios
      i = Integer.to_string(i) |> String.pad_leading(4, "0")

      {:ok, device} =
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
    end)
  end
end

N.set_log_level(:info)
N.seed()
