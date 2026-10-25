using Microsoft.Extensions.Configuration;
using System;


namespace Attendance.Utils
{
    public class ConfigHelper
    {
        public static IConfigurationRoot InitConfig()
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile("appsettings.local.json", optional: true, reloadOnChange: true);

            return builder.Build();
        }
    }
}
