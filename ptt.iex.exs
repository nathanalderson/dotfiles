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
  def set_log_level(level \\ :info), do: Logger.configure(level: level)
  def dont_truncate(), do: IEx.configure(inspect: [limit: :infinity, printable_limit: :infinity])

  def me(), do: UnsecuredUsers.get_user_by_email("nathan@tangotango.net")
  def tango(), do: UnsecuredOrgs.get_organization_by_name("Tango Tango")
end

N.set_log_level(:info)
