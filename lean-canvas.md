## Problem

- The vas majority of existing solutions that enable blind
  and vision impaired people to access technology are build on
  top of visual systems like desktop environments such as
  macos, windows and linux.
- The solutions that are built from the ground up with
  blind and vision impaired people in mind are extremly
  affective but only at a very small set of tasks.
- The way that some of these tools (like braille displays)
  make themselfs usable for a large set of tasks is by piggy
  backing on existing solutions like screen readers thus
  Inheriting the issue of being built on visual technology.
- Traditional graphical desktop environments rely heavily on visual interfaces and GUIs, making spatially structured information (e.g., code editors, diagrams) cumbersome or inaccessible for blind/low-vision users.
- Braille support is typically an afterthought: users must configure and bolt on screen readers and braille drivers, often leading to fragmented workflows.
- Existing solutions lack tight integration between core OS, applications, and braille displays—forcing users to stitch together disparate tools.

## Existing Alternatives

- **Screen readers + GUI**: JAWS, NVDA, Orca paired with mainstream desktops (Windows, macOS, GNOME/KDE).
- **Braille display drivers**: BRLTTY, BRLAPI integrations bolted onto standard OS environments.
- **Proprietary braille-focused devices**: BrailleNote, Readius, which offer end-to-end solutions but at high cost and with limited extensibility.

## Solution

Tactus is a braille-first desktop environment that treats braille displays as primary output. It combines a lightweight Zig-based core, Lua plugin scripting, and terminal-based UIs to deliver a cohesive, extensible platform where braille is first-class—no visual GUI required. It takes the usability of braille displays and enables them to access full computer features as well as full customisation.

## Key Metrics

- **Active installations**: number of users running Tactus daily.
- **Plugin ecosystem growth**: count of community-created Lua plugins.
- **Task completion time**: average time to perform common workflows (e.g., editing code, browsing file tree).
- **User satisfaction**: surveys on accessibility, usability, and performance.

## Unique Value Proposition

**"A desktop environment built by and for braille users—where every interaction is designed for tactile and audio-first workflows, not retrofitted."**

## High-Level Concept

**"A Linux desktop where the braille display is the screen."**

## Unfair Advantage

- Modular architecture in Zig+Lua optimized for performance, safety, and customization.

## Channels

- GitHub and OSS platforms (npm, PyPI for Lua modules).
- Accessibility conferences (CSUN, Sight Tech Global).
- Community forums (NVDA mailing list, BrailleNote user groups).
- University partnerships (pilots with assistive tech programs).

## Customer Segments

- **Primary**: Blind and low-vision technical users (developers, scientists, students).
- **Secondary**: Educational institutions, non-profits, and assistive technology centers.

## Early Adopters

- Tech-savvy blind developers seeking optimized workflows.
- University students in STEM fields needing seamless access to code.
- Accessibility labs looking to pilot open-source braille-first environments.
- Any blind or vision impaired people who are in need of a
  one stop shop for customisation and integration.

## Cost Structure

- Core development (Zig/Lua engineering time).
- Infrastructure: CI servers, documentation hosting, plugin registry.
- Community support and outreach (workshops, webinars).

## Revenue Streams

- **Consulting & support**: paid integration, customization, and training services.
- **Pre-installed systems**: selling or licensing Tactus-enabled hardware for schools and organizations.
- **Donations & grants**: open-source sponsorships, government and non-profit grants.
- **Enterprise subscriptions**: premium features or SLAs for institutional deployments.
