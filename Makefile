#
# Makefile
#
# Copyright (C) 2008-2018 Veselin Penev  https://bitdust.io
#
# This file (Makefile) is part of BitDust Software.
#
# BitDust is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# BitDust Software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BitDust Software.  If not, see <http://www.gnu.org/licenses/>.
#
# Please contact us if you have any questions at bitdust.io@gmail.com


build_dmg:
	@echo "building dist/BitDustDesktop.dmg"
	@rm -vrf ./dist/BitDustDesktop.dmg
	@npm run dist-mac
	@echo ""
	@echo "compress dist/BitDustDesktop.dmg to dist/BitDustDesktop_dmg.zip"
	@rm -vrf ./BitDustDesktop.zip
	@mv ./dist/BitDustDesktop.dmg .
	@zip -v -9 BitDustDesktop.zip BitDustDesktop.dmg
	@rm -vrf BitDustDesktop.dmg
	@mv ./BitDustDesktop.zip ./BitDustDesktop_dmg.zip
	@echo ""
	@echo "DONE!   now you should upload file BitDustDesktop_dmg.zip to GitHub releases page"
	@echo ""


build_deb:
	@echo "building dist/BitDustDesktop.deb"
	@rm -vrf ./dist/BitDustDesktop.deb
	@npm run dist-deb
	@echo ""
	@echo "compress dist/BitDustDesktop.deb to dist/BitDustDesktop_deb.zip"
	@rm -vrf ./BitDustDesktop.zip
	@mv ./dist/BitDustDesktop.deb .
	@zip -v -9 BitDustDesktop.zip BitDustDesktop.deb
	@rm -vrf BitDustDesktop.deb
	@mv ./BitDustDesktop.zip ./BitDustDesktop_deb.zip
	@echo ""
	@echo "DONE!   now you should upload file BitDustDesktop_deb.zip to GitHub releases page"
	@echo ""


build_exe:
	@echo "building dist/BitDustDesktop.exe"
	@rm -vrf ./dist/BitDustDesktop.exe
	@npm run dist-win
	@echo ""
	@echo "compress dist/BitDustDesktop.exe to dist/BitDustDesktop_exe.zip"
	@rm -vrf BitDustDesktop.zip
	@mv ./dist/BitDustDesktop.exe .
	@zip -v -9 BitDustDesktop.zip BitDustDesktop.exe
	@rm -vrf BitDustDesktop.exe
	@mv ./BitDustDesktop.zip ./BitDustDesktop_exe.zip
	@echo ""
	@echo "DONE!   now you should upload file BitDustDesktop_exe.zip to GitHub releases page"
	@echo ""
