# FL Studio SDK - Delphi Source Files

This directory contains the core FL Studio plugin SDK source files for Delphi development.

⚠️ **Compilation Status**: These files require additional dependency units (FP_Def.pas, FP_Extra.pas, GenericTransport.pas) to compile successfully. See "Required Dependencies" section below.

## Core Files

- **FP_DelphiPlug.pas** - Delphi helper class with utility functions
- **FP_PlugClass.pas** - Core plugin and host class definitions

## Required Dependencies

⚠️ **Note**: These files have dependencies that are not yet included in this repository. To compile these files, you will need:

- **FP_Def.pas** - Basic type definitions (constants like `Max_Path`, `NoteMul`, `AbsPPN`, etc.)
- **FP_Extra.pas** - Extra utility functions (like `MulDiv64`, `MaxOf`, `MinOf`, `Zeros`, `MulShift16`, etc.)
- **GenericTransport.pas** - Transport control definitions

These dependency files can be found in the same source repository or may be part of the official FL Studio SDK distribution.

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

The repository includes HTML documentation for example plugins (see repository root):
- **FruityGain** - Effect plugin example (see `fruitygain_d.html` for Delphi version)
- **Sine** - Simple generator example (see `sine_d.html` for Delphi version)
- **Osc3** - Polyphonic generator example (see `osc3_d.html` for Delphi version)

These HTML files contain documentation and code snippets for reference implementations.

## License

FL Studio SDK - refer to Image-Line's SDK license terms.
