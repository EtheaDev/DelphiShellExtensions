# Delphi Shell Extensions [![License](https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg)](https://opensource.org/licenses/Apache-2.0)

**Latest Version 1.0.0 - 1 Nov 2022**

**A useful Template to build a Delphi Shell Extension to have:**

- A [Preview handler][1]  which allows you to see the SVG image and text without open it, in the "Preview Panel".
 
- A [Thumbnail handler][2] which allows you to see the SVG image into Windows Explorer.

### Features

- Supports Windows Vista, 7, 8, 10 and 11 (for 32 bits and 64 bits).

- Themes (Dark and Light) according to user preferences of Windows Theme

### Build and Installation (for Delphi developers) ###

If you have Delphi 10.4 Sydney or Delphi 11.0 Alexandria, you can manually build the project:

To manually install the DelphiShellExtensions.dll follow these steps:

1. Close all the windows explorer instances which have the preview handler active or the preview handler was used (remember the dll remains in memory until the windows explorer was closed).
  
2. Upgrade the code according to your preferences searching "TODO" and "My" keyword in all files of the project
     
3. Be careful of the GUID that you assign to your Extensions

4. To install manually the dll run the `Unregister_Register.cmd` (run-as-administrator).

5. When it's registered, you can continue to change code and rebuild the dll (beware to close all Explorer instances).

## Release Notes ##

1 Nov 2022: ver. 1.0.0
- Template with example of view of .xxx text files

## Credits

Many thanks to **Rodrigo Ruz V.** (author of [theroadtodelphi.com][3] Blog) for his wonderful work on [delphi-preview-handler][4] from which this project has used a lot of code and inspiration.

## License

Licensed under the [Apache License, Version 2.0][5] (the "License");
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

![Delphi 11 Alexandria Support](./Images/SupportingDelphi.jpg)

Related links: [embarcadero.com][6] - [learndelphi.org][7]

[1]: https://docs.microsoft.com/en-us/windows/win32/shell/preview-handlers

[2]: https://docs.microsoft.com/en-us/windows/win32/shell/thumbnail-providers

[3]: https://theroadtodelphi.com/

[4]: https://github.com/RRUZ/delphi-preview-handler

[5]: https://opensource.org/licenses/Apache-2.0

[6]: https://www.embarcadero.com/

[7]: https://learndelphi.org/

