# frozen_string_literal: true

class AddIndexesToPackageFile < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :packages_package_files, :verification_failure, where: "(verification_failure IS NOT NULL)", name: "packages_packages_verification_failure_partial"
    add_concurrent_index :packages_package_files, :verification_checksum, where: "(verification_checksum IS NOT NULL)", name: "packages_packages_verification_checksum_partial"
  end

  def down
    remove_concurrent_index :packages_package_files, :verification_failure
    remove_concurrent_index :packages_package_files, :verification_checksum
  end
end
