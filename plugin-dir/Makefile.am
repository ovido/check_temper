# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# compiler settings
prefix=@prefix@
INSTALL=@INSTALL@
INSTALL_OPTS=@INSTALL_OPTS@
libexec_SCRIPTS=check_temper

# compile
check_temper:
	sed '1d' check_temper.sh > check_temper.tmp
	echo "#!@BASH@ -w" > $(libexec_SCRIPTS)
	cat check_temper.tmp >> $(libexec_SCRIPTS)
	rm -f check_temper.tmp

# install
install:
	$(INSTALL) -D -m 755 $(INSTALL_OPTS) $(libexec_SCRIPTS) $(DESTDIR)$(prefix)/$(libexec_SCRIPTS)

# cleanup
clean:
	rm -f $(libexec_SCRIPTS)

