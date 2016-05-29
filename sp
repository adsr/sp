#!/usr/bin/env php
<?php

class Sp {

    // Print usage
    function usage() {
        echo "Usage:\n" .
            "    sp        # Print paths visible in screen/tmux\n" .
            "    sp <num>  # Print path at index <num>\n" .
            "    sp <str>  # Print first path matching <str>\n";
            "    sp @<str>  # Print all paths matching <str>\n";
    }

    // Entry point
    function run() {
        $exit_status = 0;
        $arg = isset($_SERVER['argv'][1]) ? $_SERVER['argv'][1] : null;
        if ($arg == '-h' || $arg == '--help') {
            $this->usage();
        } else if (($screen_id = $this->getScreenId()) === false) {
            fwrite(STDERR, "Could not detect parent screen or tmux session.\n");
            $exit_status = 1;
        } else {
            $paths = $this->extractPathsFromScreen($screen_id);
            if (is_numeric($arg)) {
                $i = (int)$arg;
                if ($i >= 0 && $i < count($paths)) {
                    echo "{$paths[$i]}\n";
                } else {
                    fwrite(STDERR, "Path index {$i} out of range.\n");
                    $exit_status = 1;
                }
            } else if (strlen($arg) > 0) {
                $match_one = true;
                if (substr($arg, 0, 1) == '@') {
                    $match_one = false;
                    $arg = substr($arg, 1);
                }
                $found = false;
                foreach ($paths as $path) {
                    if (stripos($path, $arg) !== false) {
                        echo "{$path}\n";
                        $found = true;
                        if ($match_one) {
                            break;
                        }
                    }
                }
                if (!$found) {
                    $exit_status = 1;
                }
            } else {
                $width = max(1, (int)log10(count($paths)));
                foreach ($paths as $i => $path) {
                    printf("%{$width}d %s\n", $i, $path);
                }
            }
        }
        exit($exit_status);
    }

    // Return a 2-tuple [<screen_type>, <screen_id>] or FALSE
    function getScreenId() {
        if (($env_tmux = getenv('TMUX')) !== false) {
            return ['tmux', $env_tmux];
        } else if (($env_screen = getenv('STY')) !== false) {
            return ['screen', $env_screen];
        }
        return false;
    }

    // Return paths from screen/tmux buffer
    function extractPathsFromScreen($screen_id) {
        //mktemp
        $tmp = tempnam(sys_get_temp_dir(), 'pmp');
        if ($screen_id[0] == 'tmux') {
            exec("tmux capture-pane \; save-buffer -b 0 $tmp \; delete-buffer -b 0");
        } else if ($screen_id[0] == 'screen') {
            exec("screen -S {$screen_id[1]} -X hardcopy $tmp");
        }
        $str = file_get_contents($tmp);
        unlink($tmp);
        return $this->extractPathsFromString($str);
    }

    // Return an array of valid paths in `$str`
    function extractPathsFromString($str) {
        $paths = [];
        $words = preg_split('/\s+/', $str);
        foreach ($words as $word) {
            if ($word !== '.' && $word !== '..' && file_exists($word)) {
                $paths[] = $word;
            }
        }
        return array_values(array_unique($paths));
    }

}

(new Sp())->run();
