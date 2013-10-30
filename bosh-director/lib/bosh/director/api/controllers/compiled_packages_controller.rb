require 'bosh/director/api/controllers/base_controller'
require 'bosh/director/api/stemcell_manager'
require 'bosh/director/compiled_package_group'
require 'bosh/director/compiled_packages_exporter'

module Bosh::Director
  module Api::Controllers
    class CompiledPackagesController < BaseController
      get '/stemcells/:stemcell_name/:stemcell_version/releases/:release_name/:release_version/compiled_packages' do
        stemcell_manager = Api::StemcellManager.new
        stemcell = stemcell_manager.find_by_name_and_version(params[:stemcell_name], params[:stemcell_version])

        release_manager = Api::ReleaseManager.new
        release = release_manager.find_by_name(params[:release_name])
        release_version = release_manager.find_version(release, params[:release_version])

        compiled_packages = CompiledPackageGroup.new(release_version, stemcell)
        output_dir = File.join(Dir.tmpdir, 'compiled_packages')
        FileUtils.mkdir_p(output_dir)
        exporter = CompiledPackagesExporter.new(compiled_packages, App.instance.blobstores.blobstore)

        output_path = File.join(output_dir, "compiled_packages_#{Time.now.to_f}.tar.gz")
        exporter.export(output_path)

        send_file output_path, type: :tgz
      end
    end
  end
end