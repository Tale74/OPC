using System;
using System.IO;
using System.Text;

internal static class ValidateUtf8Bom
{
    private static int Main(string[] args)
    {
        if (args.Length == 0)
        {
            Console.Error.WriteLine("Usage: validate_utf8_bom <file> [file ...]");
            return 2;
        }

        var strictUtf8 = new UTF8Encoding(false, true);
        var failed = false;

        foreach (var path in args)
        {
            try
            {
                var bytes = File.ReadAllBytes(path);
                var hasBom = bytes.Length >= 3
                    && bytes[0] == 0xEF
                    && bytes[1] == 0xBB
                    && bytes[2] == 0xBF;

                strictUtf8.GetString(bytes);

                if (hasBom)
                {
                    Console.WriteLine("FAIL BOM: " + path);
                    failed = true;
                }
                else
                {
                    Console.WriteLine("PASS UTF8_NO_BOM: " + path);
                }
            }
            catch (Exception error)
            {
                Console.WriteLine("FAIL UTF8: " + path + " - " + error.Message);
                failed = true;
            }
        }

        return failed ? 1 : 0;
    }
}
