module Network.Mail.Parse.Types where

import Data.Text
import qualified Data.ByteString.Char8 as BS
import GHC.Generics
import Data.Aeson
import Data.Time.LocalTime (ZonedTime)

type UID = Integer
data EmailMessage = EmailMessage {
  flags :: Maybe [Flag],

  origDate :: !ZonedTime,
  from :: !EmailAddress,
  sender :: Maybe EmailAddress,
  replyTo :: Maybe EmailAddress,
  to :: Maybe [EmailAddress],
  cc :: Maybe [EmailAddress],
  bcc :: Maybe [EmailAddress],
  messageId :: Maybe MessageId,
  inReplyTo :: Maybe MessageId,
  references :: Maybe [MessageId],
  subject :: Maybe Text,
  comments :: Maybe Text,
  keywords :: Maybe [Text],

  emailHeaders :: ![Header],
  emailBodies :: ![EmailBody]
} deriving (Generic, Show)

data Flag = FSeen
          | FAnswered
          | FFlagged
          | FDeleted
          | FDraft
          | FOther Text
          deriving (Generic, Show, Eq)

type MessageId = Text

data EmailAddress = EmailAddress {
  emailAddress :: !Text,
  emailLabel :: Maybe Text
} deriving (Generic, Show)

instance Eq EmailAddress where
  x == y = emailAddress x == emailAddress y

data Header = Header {
  headerName :: !Text,
  headerContents :: !Text
} deriving (Generic, Show)

-- |An email body contains the contents of an email part
-- up until the boundary marker.
data EmailBody
  -- |Body of a MIME message part. Contains headers
  = MIMEBody { mimeHeaders :: ![Header], mimeBody :: !Text}
  -- |If the message contained no MIME information, it's probably
  -- just some text. Best guess decoding into UTF-8 is applied
  | TextBody !Text
  -- |Attachement is a part of a MIME message, but a rather special
  -- one. It's decoded from whatever the transfer encoding was applied
  -- and left as a raw sollection of bytes for your enjoyment
  | Attachment {
    attachmentHeaders :: ![Header],
    attachmentName :: !Text,
    attachmentBody :: Maybe BS.ByteString,
    -- |Location of the actual filename on disk
    storageFilename :: Maybe Text
  }
  deriving (Generic, Show)

-- Please forgive me, gods of good code
instance ToJSON BS.ByteString where
  toJSON _ = toJSON ("" :: Text)

instance FromJSON BS.ByteString where
  parseJSON _ = return BS.empty

instance ToJSON EmailMessage
instance ToJSON Header
instance ToJSON EmailBody
instance ToJSON EmailAddress
instance ToJSON Flag
instance FromJSON EmailMessage
instance FromJSON Header
instance FromJSON EmailBody
instance FromJSON EmailAddress
instance FromJSON Flag