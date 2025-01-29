%bcond_without check


%global commit ###
%global shortcommit %{sub %{commit} 1 7}
%global commitdate ###

Name:           gauntlet
Version:        ###
Release:        %autorelease
Summary:        Raycast-inspired open-source cross-platform application launcher with React-based plugins 
License:        MPL-2.0
URL:            https://github.com/project-gauntlet/gauntlet

Source0:        https://github.com/project-gauntlet/gauntlet/archive/%{commit}/cosmic-comp-%{shortcommit}.tar.gz
Source1:        vendor-%{shortcommit}.tar.gz
Source2:        vendor-config-%{shortcommit}.toml

BuildRequires:  cargo-rpm-macros >= 25
BuildRequires:  rustc
BuildRequires:  lld
BuildRequires:  cargo
BuildRequires:  libxkbcommon-devel
BuildRequires:  nodejs
BuildRequires:  npm


%global _description %{expand:
%{summary}.}

%description %{_description}

%prep
%autosetup -n gauntlet-%{commit} -p1 -a1
%cargo_prep -N
cat %{SOURCE2} >> .cargo/config.toml
echo "Appended %{SOURCE2} to .cargo/config.toml"

%build
npm ci
npm run build
%cargo_build -- --features release
%{cargo_license_summary}
%{cargo_license} > LICENSE.dependencies
%{cargo_vendor_manifest}
sed 's/\(.*\) (.*#\(.*\))/\1+git\2/' -i cargo-vendor.txt

%install
install -Dm0755 target/release/gauntlet %{buildroot}/%{_bindir}/gauntlet
install -Dm0644 assets/gauntlet.desktop %{buildroot}/%{_datadir}/applications/gauntlet.desktop
install -Dm0644 assets/gauntlet.png %{buildroot}/%{_datadir}/icons/hicolor/256x256/apps/gauntlet.png
install -Dm0644 assets/gauntlet.service %{buildroot}/%{_userunitdir}/gauntlet.service

%if %{with check}
%check
%cargo_test
%endif

%files
%license LICENSE
%license LICENSE.dependencies
%license cargo-vendor.txt
%{_bindir}/gauntlet	
%{_datadir}/applications/gauntlet.desktop
%{_datadir}/icons/hicolor/256x256/apps/gauntlet.png
%{_userunitdir}/gauntlet.service

%changelog
%autochangelog
