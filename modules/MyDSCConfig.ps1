﻿Configuration MyDSCConfig {
    Node $AllNodes.NodeName {
        Script RunShellScript {
            GetScript = {
                return @{ Result = "NotImplemented" }
            }
            SetScript = {
                & "/bin/bash /home/ubuntu/democustomescript_sh.sh"  # Path to your shell script on the VM
            }
            TestScript = {
                return $false  # Always run the shell script
            }
        }
    }
}

# Compile and start the DSC configuration
MyDSCConfig -OutputPath ./MyDSCOutput
Start-DscConfiguration -Path ./MyDSCOutput -Wait -Verbose
