require_relative "../../../../base"

describe "VagrantPlugins::GuestArch::Cap::ChangeHostName" do
  let(:described_class) do
    VagrantPlugins::GuestArch::Plugin
      .components
      .guest_capabilities[:arch]
      .get(:change_host_name)
  end

  let(:machine) { double("machine") }
  let(:communicator) { VagrantTests::DummyCommunicator::Communicator.new(machine) }

  before do
    allow(machine).to receive(:communicate).and_return(communicator)
  end

  after do
    communicator.verify_expectations!
  end

  describe ".change_host_name" do
    let(:hostname) { "example.com" }

    it "sets the hostname" do
      communicator.stub_command("sudo hostname | grep '#{hostname}'", exit_code: 1)
      communicator.expect_command("hostnamectl set-hostname #{hostname}")
      described_class.change_host_name(machine, hostname)
    end

    it "does not change the hostname if already set" do
      communicator.stub_command("sudo hostname | grep '#{hostname}'", exit_code: 0)
      described_class.change_host_name(machine, hostname)
      expect(communicator.received_commands.size).to eq(1)
    end
  end
end
