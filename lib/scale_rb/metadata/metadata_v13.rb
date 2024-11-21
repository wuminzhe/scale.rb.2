# frozen_string_literal: true

module ScaleRb
  module Metadata
    module MetadataV13
      TYPES = {
        'MetadataV13' => {
          'modules' => 'Vec<ModuleMetadataV13>',
          'extrinsic' => 'ExtrinsicMetadataV13'
        },

        'ModuleMetadataV13' => {
          'name' => 'Text',
          'storage' => 'Option<StorageMetadataV13>',
          'calls' => 'Option<Vec<FunctionMetadataV13>>',
          'events' => 'Option<Vec<EventMetadataV13>>',
          'constants' => 'Vec<ModuleConstantMetadataV13>',
          'errors' => 'Vec<ErrorMetadataV13>',
          'index' => 'u8'
        },
        'StorageMetadataV13' => {
          'prefix' => 'Text',
          'items' => 'Vec<StorageEntryMetadataV13>'
        },
        'StorageEntryMetadataV13' => {
          'name' => 'Text',
          'modifier' => 'StorageEntryModifierV13',
          'type' => 'StorageEntryTypeV13',
          'fallback' => 'Bytes',
          'docs' => 'Vec<Text>'
        },
        'StorageEntryModifierV13' => 'StorageEntryModifierV12',
        'StorageEntryTypeV13' => {
          '_enum' => {
            'plain' => 'Type',
            'map' => {
              'hasher' => 'StorageHasherV13',
              'key' => 'Type',
              'value' => 'Type',
              'linked' => 'bool'
            },
            'doubleMap' => {
              'hasher' => 'StorageHasherV13',
              'key1' => 'Type',
              'key2' => 'Type',
              'value' => 'Type',
              'key2Hasher' => 'StorageHasherV13'
            },
            'nMap' => {
              'keyVec' => 'Vec<Type>',
              'hashers' => 'Vec<StorageHasherV13>',
              'value' => 'Type'
            }
          }
        },
        'StorageHasherV13' => 'StorageHasherV12',
        'FunctionMetadataV13' => 'FunctionMetadataV12',
        'EventMetadataV13' => 'EventMetadataV12',
        'ModuleConstantMetadataV13' => 'ModuleConstantMetadataV12',
        'ErrorMetadataV13' => 'ErrorMetadataV12',
        'ExtrinsicMetadataV13' => 'ExtrinsicMetadataV12'
      }.freeze
    end
  end
end
