<blockquote class="f1 fw7 lh-title moon-gray">
  <p>
    A music player that connects to your
    cloud &amp; distributed storage
  </p>
</blockquote>

[Return to the application](../)

#### Links

🕸 [Web version](https://diffuse.sh/)  
🖥 [Native version](https://github.com/icidasset/diffuse/releases)  
⚗️ [Github repository](https://github.com/icidasset/diffuse)  



## Which services does it use?

Diffuse uses two layers of services, these layers are:

1. User layer
2. Music layer


### User layer

This layer will use a service to store data from a user, such as the user's favourites, their playlists and data from the processed music files.

You can choose between these services:

- [Blockstack](https://blockstack.org/)
- [Dropbox](https://www.dropbox.com/)
- [IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API) <small>(browser)</small>
- [IPFS](https://ipfs.io/) <small>(using MFS)</small>
- [RemoteStorage](https://remotestorage.io/)
- [Textile](https://github.com/textileio/go-textile)


### Music layer

This layer connects with the services the user has on which music can be found. No data is written to these services. You can combine all of the following services:

- [Amazon S3](https://aws.amazon.com/s3/)
- [Azure Blob Storage](https://azure.microsoft.com/en-us/services/storage/blobs/)
- [Azure File Storage](https://azure.microsoft.com/en-us/services/storage/files/)
- [Dropbox](https://dropbox.com/)
- [Google Drive](https://drive.google.com/)
- [IPFS](https://ipfs.io/) <small>(supports DNSLink & IPNS)</small>
- [WebDAV](https://en.wikipedia.org/wiki/WebDAV)



<div id="How" />

## How does it work?

Diffuse locates all the music files on the given services, extracts the metadata and then stores it via the user layer (which was explained before).


### Supported File Formats

- MP3
- MP4/M4A
- FLAC
- OGG
- WAV
- WEBM


<div id="CORS" />

### CORS

There's only one thing you need to do yourself so that your service will work with the application, and that's setting up [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) (Cross-Origin Resource Sharing). Here are the instructions you'll need for each service:

<div id="CORS__S3" />

#### Amazon S3

You can find the CORS configuration editor under the "Permissions" tab, on the S3 AWS Console.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>HEAD</AllowedMethod>
    <MaxAgeSeconds>31536000</MaxAgeSeconds>
    <ExposeHeader>Content-Length</ExposeHeader>
    <ExposeHeader>Content-Type</ExposeHeader>
    <AllowedHeader>Range</AllowedHeader>
</CORSRule>
</CORSConfiguration>
```

<div id="CORS__Dropbox" />

#### Dropbox

_Not necessary._

<div id="CORS__Google-Drive" />

#### Google Drive

_Not necessary._

<div id="CORS__IPFS" />

#### IPFS

Add the domain of the app, with the protocol, to the __list of allowed origins__.  

```shell
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["https://diffuse.sh"]'
```

You can also make this change in the Web UI, you'll find it under "Settings → IPFS Config".

```json
{
  "API": {
    "HTTPHeaders": {
      "Access-Control-Allow-Origin": [
        "https://diffuse.sh"
      ]
    }
  }
}
```

<div id="CORS__Azure" />

#### Microsoft Azure Storage

You can find the CORS configuration under the "Settings -> CORS".  
Then fill in the following in the input boxes (left to right):

```
ALLOWED ORIGINS       *
ALLOWED METHODS       GET, HEAD
ALLOWED HEADERS       Range
EXPOSED HEADERS       Content-Length, Content-Range
MAX AGE               0
```

<div id="CORS__Textile" />

#### Textile

Add the domain of the app, with the protocol, to the __list of allowed origins__ in the configuration.

```json
{
  "API": {
    "HTTPHeaders": {
      "Access-Control-Allow-Origin": [
        "https://diffuse.sh"
      ]
    }
  }
}
```

<div id="CORS__WebDAV" />

#### WebDAV

__Depends on your WebDAV server.__  
Example setup for Henrique Dias's [WebDAV server](https://github.com/hacdias/webdav):

```yaml
cors:
  enabled: true
  credentials: true

  allowed_headers:
    - Authorization
    - Content-Type
    - Depth
    - Range
  allowed_methods:
    - GET
    - HEAD
    - PROPFIND
  allowed_hosts:
    - https://diffuse.sh
  exposed_headers:
    - Content-Length
    - Content-Type
```



<div id="UI" />

## UI

There are a few "hidden" features:

- You can reorder items in the queue or a playlist with drag-and-drop.
  Select the item you want to move by tapping on it, then tap and hold to move it around.
- You can select multiple tracks using the SHIFT key and then add that selection
  to the queue or a playlist by right clicking on the selection (desktop only).
- Click on the now-playing bit to scroll to that track.
- Double tap on a EQ setting to reset it to its default value.
- Use the ALT key whilst right clicking on a track to show the alternative track-context menu.

### Search

```shell
# Show me every track where the title, artist or album contains the term 'Parkway' and the term 'Drive'. Terms are separated by spaces (eg. "Killing with a smile" has four terms).
Parkway Drive

# Show me every track of which the artist's name contains 'park'.
artist:park*

# Show me every track from Parkway Drive's "Deep Blue" album.
artist:Parkway Drive album:Deep Blue

# Show me every track from Parkway Drive but not their "Atlas" album.
artist:Parkway Drive - album:Atlas
```



<div id="QA" />

## Q&A

### I used version one, where's my data?

There's a small link, or button if you will, on the "Settings -> Import / Export"
page that will allow you to import data from version 1 of the app. Note that this
will need to reflect the authentication/storage method you chose in version 1.
