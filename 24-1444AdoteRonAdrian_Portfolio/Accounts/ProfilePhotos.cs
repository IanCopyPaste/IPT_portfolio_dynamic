using System;
using System.Globalization;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // The portrait ContentPage draws in its hero. The file is written under ~/uploads and only its
    // path goes in the database, so the image is served as an ordinary static file rather than
    // streamed back through a page on every request.
    public static class ProfilePhotos
    {
        public const string Folder = "uploads";

        // Comfortably more than a portrait needs, and well under the 4MB request cap ASP.NET
        // applies by default, so an oversized file is rejected with a message rather than by IIS.
        public const int MaxBytes = 2 * 1024 * 1024;

        // Handed to the file input's accept attribute, which is what narrows the file explorer's
        // own filter. Extensions first and media types after: between the two every browser has
        // something it understands, and a dialog that offers nothing but .jpg/.jpeg/.png is one
        // fewer way to pick a file that was never going to be accepted.
        public const string Accept = ".jpg,.jpeg,.png,image/jpeg,image/png";

        public const string TypeMessage = "Only PNG or JPEG images.";
        public const string SizeMessage = "Keep the image under 2 MB.";

        // Used as part of the generated file name.
        public const string HomeSlot = "home";

        // What the file has to start with to be what its extension claims. Checked because an
        // extension is only a promise: anything at all can be renamed to .png. The PNG signature
        // is taken in full rather than its first four bytes -- the tail is the line-ending trap
        // that catches a file mangled on the way here, and half a check is not a check.
        private static readonly byte[] PngMagic = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A };
        private static readonly byte[] JpegMagic = { 0xFF, 0xD8, 0xFF };

        // The only two media types a browser may claim for an upload here. Its word proves nothing
        // -- it mostly derives this from the extension it was handed -- so this turns away the
        // careless case cheaply and the magic bytes are what actually decide.
        private static readonly string[] AllowedTypes = { "image/png", "image/jpeg" };

        // Puts the same limits the server enforces onto the file input itself, so the file explorer
        // filters by them and the page can refuse a bad pick without a post-back. Set here rather
        // than written into the markup so each limit has one source of truth.
        public static void Apply(FileUpload upload)
        {
            upload.Attributes["accept"] = Accept;
            upload.Attributes["data-max-bytes"] = MaxBytes.ToString(CultureInfo.InvariantCulture);
            upload.Attributes["data-type-message"] = TypeMessage;
            upload.Attributes["data-size-message"] = SizeMessage;
        }

        // "uploads/34-home-20260920143005.png" as the browser should ask for it. Empty when the
        // user hasn't uploaded one, which is what the page checks.
        public static string Url(string storedPath)
        {
            return string.IsNullOrWhiteSpace(storedPath) ? "" : "/" + storedPath.Replace(Path.DirectorySeparatorChar, '/');
        }

        // Writes the upload and returns its stored path, deleting the portrait it replaces once
        // the new file is safely on disk.
        // The message for a file that can't be accepted, or null when there is nothing to object
        // to -- including when no file was chosen at all, which just means "keep the current one".
        // Separate from Save so the whole form can be checked before anything is written to disk.
        public static string Check(FileUpload upload)
        {
            if (upload == null || !upload.HasFile)
            {
                return null;
            }

            if (upload.PostedFile.ContentLength > MaxBytes)
            {
                return SizeMessage;
            }

            // An empty file has no signature to disagree with, so it would walk straight through
            // the test below.
            if (upload.PostedFile.ContentLength <= 0)
            {
                return TypeMessage;
            }

            string extension = Extension(upload.FileName);

            // Three things have to agree before the file is kept: the extension, the media type the
            // browser sent, and the bytes themselves. Only the last is evidence -- the other two
            // are the user's side of the story, and anything at all can be renamed to .png -- but
            // a file that fails any one of them is not what was asked for.
            return extension == null || !IsAllowedType(upload.PostedFile.ContentType) ||
                !HasMagic(upload.PostedFile.InputStream, extension)
                ? TypeMessage : null;
        }

        public static string Save(FileUpload upload, int userId, string slot, string current)
        {
            // Check has already passed by the time this runs, so a file here is one we will keep.
            if (upload == null || !upload.HasFile)
            {
                return current;
            }

            string extension = Extension(upload.FileName);

            // The name is ours, never the user's: a name they chose could carry a path or a second
            // extension. The timestamp makes each save a new URL, so a replaced portrait can't be
            // served from the browser's cache.
            string name = userId.ToString(CultureInfo.InvariantCulture) + "-" + slot + "-" +
                DateTime.UtcNow.ToString("yyyyMMddHHmmssfff", CultureInfo.InvariantCulture) + extension;
            string folder = HttpContext.Current.Server.MapPath("~/" + Folder);

            Directory.CreateDirectory(folder);
            upload.PostedFile.SaveAs(Path.Combine(folder, name));

            Delete(current);
            return Folder + "/" + name;
        }

        // Best effort: a portrait left behind is untidy, not broken, so a file that is locked or
        // already gone must not fail the save that replaced it.
        public static void Delete(string storedPath)
        {
            if (string.IsNullOrWhiteSpace(storedPath))
            {
                return;
            }

            try
            {
                string name = Path.GetFileName(storedPath);
                string path = Path.Combine(HttpContext.Current.Server.MapPath("~/" + Folder), name);

                if (File.Exists(path))
                {
                    File.Delete(path);
                }
            }
            catch (IOException)
            {
            }
            catch (UnauthorizedAccessException)
            {
            }
        }

        // Null for anything that isn't one of the two allowed types. ".jpeg" is normalised to
        // ".jpg" so the folder doesn't end up with both spellings.
        private static string Extension(string fileName)
        {
            string extension = Path.GetExtension(fileName ?? "").ToLowerInvariant();

            if (extension == ".png")
            {
                return ".png";
            }

            return extension == ".jpg" || extension == ".jpeg" ? ".jpg" : null;
        }

        // The header can carry parameters ("image/jpeg; charset=binary") and any casing at all, so
        // it is cut back to the media type before being compared.
        private static bool IsAllowedType(string contentType)
        {
            string type = (contentType ?? "").Split(';')[0].Trim();

            for (int i = 0; i < AllowedTypes.Length; i++)
            {
                if (string.Equals(type, AllowedTypes[i], StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }

            return false;
        }

        private static bool HasMagic(Stream stream, string extension)
        {
            byte[] expected = extension == ".png" ? PngMagic : JpegMagic;
            var head = new byte[expected.Length];

            stream.Position = 0;
            int read = stream.Read(head, 0, head.Length);
            // SaveAs reads from here, so the stream is handed back as it was found.
            stream.Position = 0;

            if (read < expected.Length)
            {
                return false;
            }

            for (int i = 0; i < expected.Length; i++)
            {
                if (head[i] != expected[i])
                {
                    return false;
                }
            }

            return true;
        }
    }
}
