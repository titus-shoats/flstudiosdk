# FL Studio SDK - Delphi Source Files

This directory contains the core FL Studio plugin SDK source files for Delphi development.

## Core Files

- **FP_DelphiPlug.pas** - Delphi helper class with utility functions
- **FP_PlugClass.pas** - Core plugin and host class definitions

## Required Dependencies

These files depend on:
- **FP_Def.pas** - Basic type definitions (may need to be added)
- **GenericTransport.pas** - Transport control definitions (may need to be added)

## Usage

To create a plugin, your project should:

```pascal
uses
  FP_DelphiPlug, FP_PlugClass;

type
  TMyPlugin = class(TDelphiFruityPlug)
    // Your plugin implementation
  end;

function CreatePlugInstance(Host: TFruityPlugHost; Tag: Integer): TFruityPlug; stdcall;
begin
  Result := TMyPlugin.Create(Tag, Host);
end;

exports
  CreatePlugInstance;
```

## Plugin Types

Use these flag combinations in `TFruityPlugInfo.Flags`:

- **Effect Plugin**: `FPF_Type_Effect` (0)
- **Full Generator**: `FPF_Type_FullGen` (includes note input)
- **Hybrid Generator**: `FPF_Type_HybridGen` (uses sampler)
- **Visual Plugin**: `FPF_Type_Visual` (no audio processing)

## SDK Version

Current SDK Version: **1**

Set in `TFruityPlugInfo.SDKVersion := CurrentSDKVersion`

## Important Notes

1. **Always use `FPF_NewVoiceParams` flag** - The old voice params are obsolete
2. **Thread Safety** - Use `Lock()`/`Unlock()` or `LockMix_Shared()`/`UnlockMix_Shared()` when accessing shared data
3. **String Types** - SDK uses `PAnsiChar` for all string parameters
4. **Constructor** - Must be: `constructor Create(SetHostTag: Integer; SetPlugHost: TFruityPlugHost);`

## Examples

See the `/examples/` directory for complete working examples:
- FruityGain (effect plugin)
- Sine (simple generator)
- Osc3 (polyphonic generator)

## License

FL Studio SDK - refer to Image-Line's SDK license terms.
