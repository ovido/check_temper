Name:		nagios-plugins-temper
Version:	1.3
Release:	1%{?dist}
Summary:	TEMPer temperature plugin for Icinga/Nagios

Group:		Applications/System
License:	GPLv2+
URL:		https://labs.ovido.at/monitoring
Source0:	check_temper-%{version}.tar.gz
BuildRoot:	%{_tmppath}/check_temper-%{version}-%{release}-root

%description
This plugin for Icinga/Nagios is used to monitor temperature and humidity
with TEMPer humi thermometers.

%prep
%setup -q -n check_temper-%{version}

%build
%configure --prefix=%{_libdir}/nagios/plugins \
	   --with-nagios-user=nagios \
	   --with-nagios-group=nagios

make all


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT INSTALL_OPTS=""

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(0755,nagios,nagios)
%{_libdir}/nagios/plugins/check_temper
%doc README INSTALL NEWS ChangeLog COPYING



%changelog
* Wed Mar 27 2013 Rene Koch <r.koch@ovido.at> 1.3-1
- Initial build.

