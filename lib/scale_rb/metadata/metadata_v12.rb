# frozen_string_literal: true

module ScaleRb
  module Metadata
    module MetadataV12
      TYPES = {
        'ErrorMetadataV12' => 'ErrorMetadataV11',
        'EventMetadataV12' => 'EventMetadataV11',
        'ExtrinsicMetadataV12' => 'ExtrinsicMetadataV11',
        'FunctionArgumentMetadataV12' => 'FunctionArgumentMetadataV11',
        'FunctionMetadataV12' => 'FunctionMetadataV11',
        'MetadataV12' => {
          'modules' => 'Vec<ModuleMetadataV12>',
          'extrinsic' => 'ExtrinsicMetadataV12'
        },
        'ModuleConstantMetadataV12' => 'ModuleConstantMetadataV11',
        'ModuleMetadataV12' => {
          'name' => 'Text',
          'storage' => 'Option<StorageMetadataV12>',
          'calls' => 'Option<Vec<FunctionMetadataV12>>',
          'events' => 'Option<Vec<EventMetadataV12>>',
          'constants' => 'Vec<ModuleConstantMetadataV12>',
          'errors' => 'Vec<ErrorMetadataV12>',
          'index' => 'u8'
        },
        'StorageEntryModifierV12' => 'StorageEntryModifierV11',
        'StorageEntryMetadataV12' => 'StorageEntryMetadataV11',
        'StorageEntryTypeV12' => 'StorageEntryTypeV11',
        'StorageMetadataV12' => 'StorageMetadataV11',
        'StorageHasherV12' => 'StorageHasherV11'
      }.freeze
    end
  end
end
