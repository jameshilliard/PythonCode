# Misc. utilities for the test system

module TestUtilities
    def scatter_range(range, amount)
        new_list = ""
        low = range.split('-')[0].to_i
        high = range.split('-')[1].to_i
        srand
        amount.times do
            new_list << "#{rand(high-low)+low},"
        end
        return new_list.sub(/,\z/,'')
    end

    def spc_range(replace)
        if replace.include?("-")
            new_range1_start = (replace.split(":")[1].split("-")[0].to_i) - (rand(4)+2)
            new_range1_end = (replace.split(":")[1].split("-")[0].to_i) - 1

            new_range2_start = (replace.split(":")[1].split("-")[1].to_i) + 1
            new_range2_end = (replace.split(":")[1].split("-")[1].to_i) + (rand(4)+2)
            return "#{new_range1_start}-#{new_range1_end},#{new_range2_start}-#{new_range2_end}"
        else
            new_range1_start = (replace.split(":")[1].to_i) - (rand(4)+2)
            new_range1_end = (replace.split(":")[1].to_i) - 1

            new_range2_start = (replace.split(":")[1].to_i) + 1
            new_range2_end = (replace.split(":")[1].to_i) + (rand(4)+2)
            return "#{new_range1_start}-#{new_range1_end},#{new_range2_start}-#{new_range2_end}"
        end
    end

    def spc_check(list1, list2)
        list1.split(',').each { |check| return FALSE if list2.include?(check) }
        return TRUE
    end

    def expand(list)
        new_list = ""
        list.split(',').each do |check|
            if check.include?("-")
                check.include?(":") ? prefix = check.slice!(/\A\w+?:/) : prefix = ""
                check.delete!('^[0-9\-]') unless prefix == ""
                for i in check.split('-')[0].to_i..check.split('-')[1].to_i
                    new_list << "#{prefix}#{i},"
                end
            else
                new_list << "#{prefix}#{check},"
            end
        end
        new_list.sub!(/,\z/, '')
        return new_list
    end

    def get_random_port(list=nil)
        raise ArgumentError,"get_random_port needs a list to choose from. Nothing was sent." if list == nil
        r_port = list.split(',')[rand(list.split(',').length)]
        r_port.strip!
        if r_port.include?('-')

            r_port.include?(":") ? prefix = r_port.slice!(/\A\w+?:/) : prefix = ""

            b = r_port.split('-')[0].to_i
            e = r_port.split('-')[1].to_i
            r_port = "#{prefix}#{rand(e-b)+b}"
        end
        return r_port
    end
end
