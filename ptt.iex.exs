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
  def device(), do:
    %Device{
      device_id: "e406733fff8a7bd1",
      name: "samsung SM-G715A",
      platform: :android,
      platform_version: "12",
      vendor: "samsung",
      model: "SM-G715A",
      token: "ey6OkLZkR3y3zA7LYN3izN:APA91bGM_BfR4VQIsLNRuDVAs3araOCWYimPD9S5R1qf5qzxPqlNcjQBqQHxQ9K6FR8tRIU4iXYxQB9qwwk7iBkipHqYCwyTaUSoGPyRHmTUoAoVBL1jy0xZm1zJuC_s15wVwtAaLQbW",
      voip_token: nil,
      app_version: "1.3.4+673",
      release_build: true,
      dnd: false,
      activation_status: :active,
      push_status: :registered,
      user_id: 6979347344739270656
    }

  def set_log_level(level \\ :info), do: Logger.configure(level: level)
  def dont_truncate(), do: IEx.configure(inspect: [limit: :infinity, printable_limit: :infinity])

  def me(), do: UnsecuredUsers.get_user_by_email("nathan@tangotango.net")
  def tango(), do: UnsecuredOrgs.get_organization_by_name("Tango Tango")

  def create_sites(count) do
    for i <- 1..count do
      num = String.pad_leading("#{i}", 2, "0")
      UnsecuredSites.create_site(%{
        name: "Site #{num}",
        mac_address: "00:00:00:00:00:#{num}",
        org_id: tango().id
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
end

N.set_log_level(:info)
