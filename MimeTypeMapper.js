/*
 * Copyright 2014 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

function startsWith(string, prefix) {
    return string.indexOf(prefix) === 0;
}

function mimeTypeToContentType(mimeType) {
    if(startsWith(mimeType, "image")) {
        return ContentType.Pictures;
    } else if(startsWith(mimeType, "audio")) {
        return ContentType.Music;
    } else if(startsWith(mimeType, "video")) {
        return ContentType.Videos;
    } else if(startsWith(mimeType, "text/x-vcard")) {
        return ContentType.Contacts;
    } else if(startsWith(mimeType, "text")) {
        return ContentType.Documents;
    } else {
        return ContentType.Unknown;
    }
}
